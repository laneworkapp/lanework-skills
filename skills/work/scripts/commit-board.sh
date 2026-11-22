#!/bin/bash
# commit-board.sh: commit named board paths only, under a lock, without touching anyone else's work.
# usage: commit-board.sh [--push] [--trailer T] "<msg>" <paths...>
# Run inside the repo (paths relative to the current directory, or absolute). Under a lock shared by
# every worktree of the repo (<git common dir>/lanework-commit-board.lock, a directory holding the
# holder's pid, created whole; a lock whose pid fails `kill -0` is reclaimed; waits up to 300 s):
# fetch origin (a failed fetch: exit 1 with --push, nothing committed; without it a warning, and the commit is local) and `merge --ff-only` onto origin/<branch> (a dirty overlap or a diverged branch stops,
# naming the files), then commit through a private GIT_INDEX_FILE read from HEAD plus only the named
# paths (`add -A` per path, literal pathspecs, so deletions and moves count; a path neither on disk nor
# in HEAD, such as a card's old lane path when it was filed since, is skipped). The message is <msg>, and
# the --trailer values (repeatable, in order, one per line) as its last paragraph only when given.
# --push pushes <branch> to origin; a rejected push un-commits (the branch ref only, files stay on
# disk) and retries from the fetch, up to 5 tries: safe only because the lock serialises commits. --push pushes the branch, so earlier unpushed commits
# on it go too. Without --push nothing leaves the machine. With --push and nothing to commit, but HEAD ahead of
# origin/<branch> (an earlier run killed or timed out mid-push): pushes HEAD, a rejected push retried the same way
# (nothing to un-commit), and after 5 tries exit 1 naming the unpushed commit.
# Push bound: each `git push` runs in its own session (a perl wrapper), so it has no terminal: a credential, passphrase
# or host-key prompt fails at once, a rejected push, rather than stopping until the bound. Its process group is killed after
# LANEWORK_PUSH_TIMEOUT seconds (default 120; with --push, not a whole number from 1 to 86400: exit 2). A timeout is never retried
# and never un-commits, as the push may have landed: the commit stays on HEAD, the cleanup runs, exit 1 with
# `push timed out after N s; <sha> committed, not confirmed pushed; run --push again`.
# Never stashes (warns if the stash count changed), never `add -A` without paths, never rebases.
# `git reset -q -- <paths>` right after the commit syncs the real index for the named paths only (anything
# the owner had staged under them is unstaged, everything else they staged stays staged), so a kill during
# the push leaves an index matching HEAD. Each un-commit restores instead: the named paths back to HEAD,
# then the owner's staged entries under them put back (intent-to-add ones too). They are saved before the
# first commit to <git dir>/lanework-commit-board.saved.<pid>.XXXXXX (mktemp, one per run), removed at exit (under
# the lock, each run also removes those of a dead pid over a day old: a kill's file stays a day for the recovery
# below); a run
# that ends with nothing of its commit on HEAD leaves the index as the owner had it. A failed restore keeps
# that file and prints how to put it back, unless a later try pushes. The EXIT trap, only while the lock is
# ours: restores when HEAD is where the commit started (taken back; reset there by the owner after a good push, said); syncs when our commit is HEAD or under
# it, or when HEAD moved off where the commit started before the commit was recorded; any other HEAD (an
# amend, a reset elsewhere): the index left alone, and it says so. With --push, a run that ends with its
# commit landed but the run not finished (a signal) says `interrupted: <sha> committed, not confirmed pushed
# (origin/<branch> does not hold it)` (no fetch refspec, a push mapped to another branch, or not pushed), or
# `committed and pushed` when origin/<branch> (the tracking ref, which a push updates) already holds it.
# A commit that fails (a hook) leaves the index alone.
# SIGTERM, SIGHUP to the script: held until the command running returns (git with its hooks, a sleep; a push
# up to the bound), then exit 143, 129 through the EXIT trap, so no git child outlives the cleanup. SIGINT the
# same (130), except that bash drops one sent to the script alone while a command runs: the run goes on.
# Sent to the process group (Ctrl-C), the git child dies too (the push wrapper passes it on to the push's session), its step fails as any failed step does, and
# the cleanup runs.
# Window left, SIGKILL only (it also leaves the saved file, swept after a day, and a dead pid's lock, reclaimed by
# the next run; the push group keeps running until it ends or the bound):
# from `git commit` starting (hooks included) to the line after it, `git status` shows the path as MM
# (`git reset -q -- <path>` makes it match HEAD); between `update-ref` and the end of the restore, the
# owner's staged entries under the named paths are lost (measured: a staged edit ` M`, a staged deletion or
# rename ` D`, a staged new file `??`); `git reset -q -- <paths>` then `git update-index -z --index-info <
# <git dir>/lanework-commit-board.saved.<pid>.XXXXXX` puts them back (intent-to-add ones need `git add -N` again).
# Prints the one-line log of the commit it made or pushed (not HEAD, which an owner may have reset meanwhile), or
# "nothing to commit" (exit 0: the named paths exist, nothing changed, and with --push nothing unpushed).
# Exit 2: a bad flag, no message, no paths, with --push a bad LANEWORK_PUSH_TIMEOUT. Exit 1, nothing committed: the save file cannot be created in the git dir, the fetch fails with --push, not in a work tree, detached HEAD,
# a path outside the work tree or the root itself, a `.DS_Store` or an owner's `comments/.draft/`
# among what would be staged, a path git cannot add, every named path skipped (none on disk or in HEAD), `git commit` failing (a
# pre-commit or commit-msg hook; the index stays as it was), --push with no origin, the lock not taken in
# time or lost, the fast-forward refused, the push failed 5 times. Exit 1, committed, not confirmed pushed: the push timed out.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE='commit-board.sh [--push] [--trailer T] "<msg>" <paths...>'
PUSH=""; TRAILERS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --push)    PUSH=1; shift ;;
    --trailer) [ $# -ge 2 ] && [ -n "$2" ] || { echo "commit-board.sh: --trailer needs a value" >&2; echo "usage: $USAGE" >&2; exit 2; }; TRAILERS+=("$2"); shift 2 ;;
    --)        shift; break ;;
    -*)        echo "commit-board.sh: unknown argument: $1" >&2; echo "usage: $USAGE" >&2; exit 2 ;;
    *)         break ;;
  esac
done
[ $# -ge 2 ] && [ -n "$1" ] || { echo "commit-board.sh: a message and at least one path" >&2; echo "usage: $USAGE" >&2; exit 2; }
MSG="$1"; shift
LIM=${LANEWORK_PUSH_TIMEOUT:-120}
badlim() { echo "commit-board.sh: LANEWORK_PUSH_TIMEOUT must be a whole number of seconds from 1 to 86400: $LIM" >&2; exit 2; }
# a ceiling, as perl's alarm on macOS sets nothing from 1000000000 up; over 5 digits refused first, so -le cannot overflow
[ -z "$PUSH" ] || case "$LIM" in ''|*[!0-9]*|0*|??????*) badlim ;; *) [ "$LIM" -le 86400 ] || badlim ;; esac

TOP=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "commit-board.sh: not inside a git work tree: $(pwd)" >&2; exit 1; }
TOP=$(cd "$TOP" && pwd -P)
REL=()
for p in "$@"; do   # resolved from the caller's directory, before the cd below
  abs=$(python3 -I -c 'import os, sys; a = os.path.normpath(os.path.abspath(sys.argv[1])); print(os.path.join(os.path.realpath(os.path.dirname(a)), os.path.basename(a)))' "$p")
  case "$abs" in
    "$TOP") echo "commit-board.sh: $p is the whole work tree; name the board files" >&2; exit 1 ;;
    "$TOP"/*) ;;
    *) echo "commit-board.sh: $p is outside the work tree $TOP" >&2; exit 1 ;;
  esac
  [ "$(basename "$abs")" != .DS_Store ] || { echo "commit-board.sh: refusing $p: .DS_Store is never committed" >&2; exit 1; }
  REL+=("${abs#"$TOP"/}")
done
cd "$TOP"
export GIT_LITERAL_PATHSPECS=1   # a path is a path: no globs, no :/ magic
BRANCH=$(git symbolic-ref -q --short HEAD) || { echo "commit-board.sh: detached HEAD; check out a branch" >&2; exit 1; }
UP="refs/remotes/origin/$BRANCH"
HAS_ORIGIN=""; if git remote get-url origin >/dev/null 2>&1; then HAS_ORIGIN=1; fi
[ -z "$PUSH" ] || [ -n "$HAS_ORIGIN" ] || { echo "commit-board.sh: --push, but the repo has no origin" >&2; exit 1; }

# ---- the lock: created whole (a temp dir holding our pid, renamed into place), so it never exists without a pid ----
LOCK="$(cd "$(git rev-parse --git-common-dir)" && pwd -P)/lanework-commit-board.lock"
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/work-commit.XXXXXX")
mvdir() { perl -e 'rename($ARGV[0], $ARGV[1]) or exit 1' "$1" "$2" 2>/dev/null; }   # rename(2): fails onto a non-empty dir
own() { [ "$(cat "$LOCK/pid" 2>/dev/null || true)" = "$$" ]; }
SAVED=""; ADD=(); OWNER=(); ITA=(); PRE=""; LANDED=""; NEW=""; KEEP=""; AHEAD=""; TIMED=""; SAVEDONE=""
release() {
  trap '' TERM INT HUP   # the cleanup runs to its end
  # only while the lock is ours: HEAD back at PRE (taken back) -> restore; our commit on HEAD or under it (or HEAD moved off
  # PRE mid-commit) -> sync; any other HEAD -> left alone, said
  if [ "${#ADD[@]}" -gt 0 ] && own; then
    local h c=""; h=$(git rev-parse HEAD 2>/dev/null || true)
    if [ -n "$LANDED" ] && [ -n "$NEW" ]; then
      if [ "$h" = "$PRE" ]; then
        if restore && [ -n "$OK" ]; then echo "commit-board.sh: HEAD reset to ${PRE:0:8} during the run, after ${NEW:0:8} was pushed; the index restored to what was staged before the run" >&2; fi
      elif git merge-base --is-ancestor "$NEW" HEAD 2>/dev/null; then git reset -q -- "${ADD[@]}" || true; c=$NEW
      else echo "commit-board.sh: HEAD moved to ${h:0:8} during the run, off ${NEW:0:8}; the index left as it is" >&2; fi
    elif [ -n "$PRE" ] && [ "$h" != "$PRE" ]; then git reset -q -- "${ADD[@]}" || true; c=$h; fi
    if [ -n "$PUSH" ] && [ -z "$OK" ] && [ -z "$TIMED" ] && [ -n "$c" ]; then   # UP is set before the trap; a missing ref reads as not confirmed
      if git merge-base --is-ancestor "$c" "$UP" 2>/dev/null; then echo "commit-board.sh: interrupted: ${c:0:8} committed and pushed" >&2
      else echo "commit-board.sh: interrupted: ${c:0:8} committed, not confirmed pushed (origin/$BRANCH does not hold it)" >&2; fi
    fi
  fi
  if own; then rm -rf "$LOCK" || true; fi; rm -rf "$STAGE" "$LOCK.$$" 2>/dev/null || true; [ -n "$KEEP" ] || [ -z "$SAVED" ] || rm -f "$SAVED" || true
}
trap release EXIT
trap 'exit 143' TERM; trap 'exit 130' INT; trap 'exit 129' HUP   # bash runs these once the foreground git returns; an INT to the pid alone while a child runs is dropped by bash
GD=$(git rev-parse --absolute-git-dir)
SAVED=$(mktemp "$GD/lanework-commit-board.saved.$$.XXXXXX" 2>/dev/null) || { SAVED=""; echo "commit-board.sh: cannot create a save file in $GD; nothing committed" >&2; exit 1; }   # per work tree, as the index is; never another run's
reclaim() {   # reclaim <dead pid>: move the lock aside, keep it gone only if it was that pid's; a live one goes back
  local aside="$LOCK.stale.$$"
  mvdir "$LOCK" "$aside" || return 0
  if [ "$(cat "$aside/pid" 2>/dev/null || true)" = "$1" ]; then
    rm -rf "$aside"; echo "commit-board.sh: reclaimed the lock of pid ${1:-none}, no longer running" >&2
  else
    mvdir "$aside" "$LOCK" || rm -rf "$aside"   # its holder finds the lock not its own and stops
  fi
}
take_lock() {
  local start pid said=""; start=$(date +%s)
  rm -rf "$LOCK.$$"; mkdir "$LOCK.$$"; echo "$$" > "$LOCK.$$/pid"
  until mvdir "$LOCK.$$" "$LOCK"; do
    pid=$(cat "$LOCK/pid" 2>/dev/null || true)
    if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then reclaim "$pid"; continue; fi
    if [ -z "$pid" ] && [ -d "$LOCK" ] && [ $(( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || date +%s) )) -gt 10 ]; then reclaim ""; continue; fi
    [ -n "$said" ] || { echo "commit-board.sh: waiting on the lock held by pid ${pid:-?} ($LOCK)" >&2; said=1; }
    [ $(( $(date +%s) - start )) -lt 300 ] || { echo "commit-board.sh: the lock is still held by pid ${pid:-?} after 300 s; nothing committed" >&2; exit 1; }
    sleep 0.2
  done
}
take_lock
# sweep, under the lock: saved files of a dead pid, over a day old (a fresh one is a kill's recovery source)
for f in "$GD"/lanework-commit-board.saved.*.*; do
  p=${f#"$GD/lanework-commit-board.saved."}; p=${p%%.*}
  case "$p" in ''|*[!0-9]*) continue ;; esac
  [ "$f" != "$SAVED" ] && [ -f "$f" ] && ! kill -0 "$p" 2>/dev/null && [ -n "$(find "$f" -mtime +1 2>/dev/null)" ] && rm -f "$f" || true
done
# push_bounded: git push in its own session under perl (no timeout(1) on macOS; no terminal, so a prompt fails at once); its
# group is killed after LIM s and it returns 124, only then (a git 124 reads 1); INT, TERM, HUP to perl are passed on to the
# group, or to the child alone before its setsid (the parent never sets the group: that races the setsid). Its stderr goes to
# push.err by a redirect on perl itself, never on the function: a trap run inside a redirected function keeps the redirect
push_bounded() {
  perl -mPOSIX -e 'my $t = shift; my $pid = fork; defined $pid or exit 125;
    if (!$pid) { POSIX::setsid(); exec @ARGV; exit 127 }
    $SIG{$_} = sub { kill $_[0], -$pid or kill $_[0], $pid } for qw(INT TERM HUP);
    $SIG{ALRM} = sub { kill "KILL", -$pid; waitpid $pid, 0; exit 124 };
    alarm $t; my $r; do { $r = waitpid $pid, 0 } until $r == $pid || $r == -1 && !$!{EINTR}; alarm 0;
    exit 1 if $r != $pid; my $s = $?; exit 128 + ($s & 127) if $s & 127; $s >>= 8; exit($s == 124 ? 1 : $s)' \
    "$LIM" git push -q origin "$BRANCH" 2>"$STAGE/push.err"
}
mine() { own || { echo "commit-board.sh: lost the lock ($LOCK); stopping, nothing more written" >&2; exit 1; }; }

# both <list a> <list b>: the lines in both (newline lists)
both() { [ -n "$1" ] && [ -n "$2" ] && grep -x -F -f <(printf '%s\n' "$2") <<<"$1" || true; }
dirty() { git diff --name-only HEAD; git ls-files --others --exclude-standard; }
# sync: fetch, then fast-forward onto origin/<branch>; stop, naming the files, on a dirty overlap or a diverged branch
sync() {
  [ -n "$HAS_ORIGIN" ] || return 0
  if ! git fetch -q origin 2>"$STAGE/fetch.err"; then
    sed 's/^/  /' "$STAGE/fetch.err" >&2 2>/dev/null || true
    [ -z "$PUSH" ] || { echo "commit-board.sh: fetch from origin failed; nothing committed" >&2; exit 1; }
    echo "commit-board.sh: fetch from origin failed; committing locally" >&2; return 0
  fi
  git rev-parse -q --verify "$UP" >/dev/null || return 0   # the branch is not on origin yet
  local base in ours
  if git merge-base --is-ancestor HEAD "$UP"; then
    [ "$(git rev-parse HEAD)" != "$(git rev-parse "$UP")" ] || return 0
    if ! git merge -q --ff-only "$UP" 2>"$STAGE/merge.err"; then
      in=$(git diff --name-only HEAD "$UP")
      echo "commit-board.sh: fast-forward to origin/$BRANCH refused; uncommitted changes overlap incoming ones:" >&2
      both "$(dirty)" "$in" | sed 's/^/  /' >&2; sed 's/^/  git: /' "$STAGE/merge.err" >&2; exit 1
    fi
  elif git merge-base --is-ancestor "$UP" HEAD; then
    return 0   # ahead of origin: --push carries those commits too
  else
    base=$(git merge-base HEAD "$UP"); in=$(git diff --name-only "$base" "$UP"); ours=$(git diff --name-only "$base" HEAD; dirty)
    common=$(both "$(printf '%s\n' "$ours" | sort -u)" "$in")
    echo "commit-board.sh: $BRANCH and origin/$BRANCH have diverged ($(git rev-list --count "$base..HEAD") local, $(git rev-list --count "$base..$UP") incoming); nothing committed." >&2
    if [ -n "$common" ]; then echo "changed on both sides:" >&2; sed 's/^/  /' <<<"$common" >&2
    else echo "no file changed on both sides: rebase or merge $BRANCH onto origin/$BRANCH, then run this again." >&2; fi
    exit 1
  fi
}

# sync_index: the real index for the named paths = HEAD's, so a later plain `git commit` cannot revert the board write
sync_index() { git reset -q -- "${ADD[@]}" || echo "commit-board.sh: warning: could not sync the real index for the named paths (git reset)" >&2; }
# save_owner, before the first commit: the owner's staged entries under the named paths that differ from PRE, as
# --index-info lines in $SAVED (each name first removed, mode 0, then its entries; a deletion has none), and the
# intent-to-add names (`add -N`, invisible to a plain diff, no blob to save) in ITA
save_owner() {
  OWNER=(); ITA=(); local f z=${PRE//?/0}
  while IFS= read -r -d '' f; do OWNER+=("$f"); done < <(git diff --cached --name-only --no-renames -z "$PRE" -- "${ADD[@]}")
  while IFS= read -r -d '' f; do [ "${#OWNER[@]}" -gt 0 ] && printf '%s\n' "${OWNER[@]}" | grep -qxF -- "$f" || ITA+=("$f")
  done < <(git diff --cached --ita-visible-in-index --name-only --no-renames --diff-filter=A -z "$PRE" -- "${ADD[@]}")
  { [ "${#OWNER[@]}" -eq 0 ] || { for f in "${OWNER[@]}"; do printf '0 %s\t%s\0' "$z" "$f"; done; git ls-files -s -z -- "${OWNER[@]}"; }; } > "$SAVED"
}
# restore_index: the named paths back to HEAD, then the saved entries and the intent-to-add names put back; a missing
# $SAVED fails (empty: nothing to put back)
restore_index() {
  git reset -q -- "${ADD[@]}" || return 1
  [ -e "$SAVED" ] || { echo "commit-board.sh: the saved entries ($SAVED) are gone" >&2; return 1; }
  [ ! -s "$SAVED" ] || git update-index -z --index-info < "$SAVED" || return 1
  local f; [ "${#ITA[@]}" -eq 0 ] || for f in "${ITA[@]}"; do { [ ! -e "$f" ] && [ ! -L "$f" ]; } || git add -N -f -- "$f" || return 1; done
}
# restore: restore_index, or say so, keep $SAVED and print how to put it back
restore() {
  restore_index && { KEEP=""; return 0; }
  KEEP=1; echo "commit-board.sh: warning: could not restore the index for the named paths" >&2
  [ ! -e "$SAVED" ] || { printf 'commit-board.sh: the saved entries are kept in %s; to put them back:\n  git reset -q --' "$SAVED"; printf ' %q' "${ADD[@]}"
    printf '\n  git update-index -z --index-info < %q\n' "$SAVED"; [ "${#ITA[@]}" -eq 0 ] || { printf '  git add -N --'; printf ' %q' "${ITA[@]}"; printf '\n'; }; } >&2
  return 1
}
STASH0=$(git stash list | wc -l | tr -d ' ')
{ printf '%s\n' "$MSG"; [ "${#TRAILERS[@]}" -eq 0 ] || { printf '\n'; printf '%s\n' "${TRAILERS[@]}"; }; } > "$STAGE/msg"
OK=""; KEPT="the index untouched"
for try in 1 2 3 4 5; do
  sync
  IDX="$STAGE/index"; rm -f "$IDX"
  GIT_INDEX_FILE="$IDX" git read-tree HEAD
  ADD=()   # a named path gone from disk and never committed (a card filed and moved since HEAD) has nothing to add
  for r in "${REL[@]}"; do
    if [ -e "$r" ] || [ -L "$r" ] || [ -n "$(GIT_INDEX_FILE="$IDX" git ls-files -- "$r")" ]; then ADD+=("$r")
    elif [ "$try" -eq 1 ]; then echo "commit-board.sh: note: $r is neither on disk nor in HEAD; skipped" >&2; fi
  done
  [ "${#ADD[@]}" -gt 0 ] || { echo "commit-board.sh: none of the named paths is on disk or in HEAD; nothing committed" >&2; exit 1; }
  GIT_INDEX_FILE="$IDX" git add -A -- "${ADD[@]}" 2>"$STAGE/add.err" || { sed 's/^/  /' "$STAGE/add.err" >&2; echo "commit-board.sh: git cannot add those paths; nothing committed" >&2; exit 1; }
  STAGED=$(GIT_INDEX_FILE="$IDX" git diff --cached --name-only HEAD)
  BAD=$(grep -E '(^|/)\.DS_Store$|(^|/)comments/\.draft(/|$)' <<<"$STAGED" || true)
  [ -z "$BAD" ] || { echo "commit-board.sh: refusing, these would be committed (.DS_Store, or an owner's unposted draft); name the files instead:" >&2; sed 's/^/  /' <<<"$BAD" >&2; exit 1; }
  if [ -z "$STAGED" ]; then
    # nothing new, but an earlier run's commit not on origin (a kill, a timed-out push): with --push, push it
    { [ -n "$PUSH" ] && git rev-parse -q --verify "$UP" >/dev/null && [ "$(git rev-list --count "$UP..HEAD")" -gt 0 ]; } || { echo "nothing to commit"; exit 0; }
    AHEAD=$(git rev-parse HEAD); LANDED=""; NEW=""; PRE=""   # nothing of this run's on HEAD: nothing to un-commit
  else
    mine
    AHEAD=""; LANDED=""; NEW=""; PRE=$(git rev-parse HEAD)   # the EXIT trap syncs the index once HEAD is no longer this (or LANDED)
    [ -n "$SAVEDONE" ] || { save_owner; SAVEDONE=1; }   # once, at the first commit (a push-only try 1 commits nothing): later tries start from the restored index, and an upstream change to a staged path stops the fast-forward
    GIT_INDEX_FILE="$IDX" git commit -q -F "$STAGE/msg" || { echo "commit-board.sh: git commit failed (a pre-commit or commit-msg hook?); nothing committed, $KEPT" >&2; exit 1; }
    LANDED=1; NEW=$(git rev-parse HEAD)
    sync_index   # before the push: a kill from here on leaves an index that matches HEAD
    [ -n "$PUSH" ] || { OK=1; break; }
  fi
  mine
  rc=0; push_bounded || rc=$?   # a failed redirect is a failed push too (rc 1, no output file)
  if [ "$rc" -eq 0 ]; then OK=1; KEEP=""; break; fi   # pushed: an earlier failed restore's entries are obsolete
  if [ "$rc" -eq 124 ]; then   # it may have landed: keep the commit, let the cleanup run, never retry
    TIMED=1; c=${NEW:-$AHEAD}; echo "commit-board.sh: push timed out after $LIM s; ${c:0:8} committed, not confirmed pushed; run --push again" >&2; exit 1
  fi
  if [ -n "$AHEAD" ]; then
    echo "commit-board.sh: push of ${AHEAD:0:8} rejected (try $try of 5); retrying" >&2
    sed 's/^/  git: /' "$STAGE/push.err" >&2 2>/dev/null || echo "  git: git push output unavailable" >&2
    sleep 1; continue
  fi
  echo "commit-board.sh: push rejected (try $try of 5); un-committing ${NEW:0:8} (ref only, files stay) and retrying" >&2
  sed 's/^/  git: /' "$STAGE/push.err" >&2 2>/dev/null || echo "  git: git push output unavailable" >&2
  mine
  git update-ref "refs/heads/$BRANCH" "$NEW^" "$NEW"
  if restore; then KEPT="the index restored to what was staged before the run"
  else KEPT="the index for the named paths NOT restored to what was staged before the run (check git status)"; fi
  LANDED=""; PRE=""   # nothing of ours on HEAD; the index is the owner's again
  sleep 1
done
[ "$(git stash list | wc -l | tr -d ' ')" = "$STASH0" ] || echo "commit-board.sh: WARNING: the stash count changed while committing; tell the coordinator" >&2
[ -n "$OK" ] || [ -z "$AHEAD" ] || { echo "commit-board.sh: push failed 5 times; ${AHEAD:0:8} (an earlier commit) committed, not pushed" >&2; exit 1; }
[ -n "$OK" ] || { echo "commit-board.sh: push failed 5 times; nothing committed, files on disk, $KEPT" >&2; exit 1; }
git log --oneline -1 "${NEW:-${AHEAD:-HEAD}}" | cat   # the run's commit, whatever HEAD is now (an owner's reset during the push)
