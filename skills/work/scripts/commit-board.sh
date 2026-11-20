#!/bin/bash
# commit-board.sh: commit named board paths only, under a lock, without touching anyone else's work.
# usage: commit-board.sh [--push] [--trailer T] "<msg>" <paths...>
# Run inside the repo (paths relative to the current directory, or absolute). Under a lock shared by
# every worktree of the repo (<git common dir>/lanework-commit-board.lock, a directory holding the
# holder's pid, created whole; a lock whose pid fails `kill -0` is reclaimed; waits up to 300 s):
# fetch origin and `merge --ff-only` onto origin/<branch> (a dirty overlap or a diverged branch stops,
# naming the files), then commit through a private GIT_INDEX_FILE read from HEAD plus only the named
# paths (`add -A` per path, literal pathspecs, so deletions and moves count; a path neither on disk nor
# in HEAD, such as a card's old lane path when it was filed since, is skipped). The message is <msg>, and
# the --trailer values (repeatable, in order, one per line) as its last paragraph only when given.
# --push pushes <branch> to origin; a rejected push un-commits (the branch ref only, files stay on
# disk) and retries from the fetch, up to 5 tries: safe only because the lock serialises commits. --push pushes the branch, so earlier unpushed commits
# on it go too. Without --push nothing leaves the machine.
# Never stashes (warns if the stash count changed), never `add -A` without paths, never rebases.
# `git reset -q -- <paths>` right after the commit syncs the real index for the named paths only (anything
# the owner had staged under them is unstaged, everything else they staged stays staged), so a kill during
# the push leaves an index matching HEAD. Each un-commit restores instead: the named paths back to HEAD,
# then the owner's staged entries under them put back (intent-to-add ones too). They are saved before the
# first commit to <git dir>/lanework-commit-board.saved.XXXXXX (mktemp, one per run), removed at exit; a run
# that ends with nothing of its commit on HEAD leaves the index as the owner had it. A failed restore keeps
# that file and prints how to put it back, unless a later try pushes. The EXIT trap, only while the lock is
# ours: restores when HEAD is where the commit started (taken back); syncs when our commit is HEAD or under
# it, or when HEAD moved off where the commit started before the commit was recorded; any other HEAD (an
# amend, a reset elsewhere): the index left alone, and it says so. With --push, a run that ends with its
# commit landed but not pushed (a signal) says `interrupted: <sha> committed, not pushed`.
# A commit that fails (a hook) leaves the index alone.
# SIGTERM, SIGHUP to the script: held until the command running returns (git with its hooks, a sleep; a hung
# push holds them), then exit 143, 129 through the EXIT trap, so no git child outlives the cleanup. SIGINT the
# same (130), except that bash drops one sent to the script alone while a command runs: the run goes on.
# Sent to the process group (Ctrl-C), the git child dies too, its step fails as any failed step does, and
# the cleanup runs.
# Window left, SIGKILL only (it also leaves the saved file and a dead pid's lock, reclaimed by the next run):
# from `git commit` starting (hooks included) to the line after it, `git status` shows the path as MM
# (`git reset -q -- <path>` makes it match HEAD); between `update-ref` and the end of the restore, the
# owner's staged entries under the named paths are lost (measured: a staged edit ` M`, a staged deletion or
# rename ` D`, a staged new file `??`); `git reset -q -- <paths>` then `git update-index -z --index-info <
# <git dir>/lanework-commit-board.saved.XXXXXX` puts them back (intent-to-add ones need `git add -N` again).
# Prints the new commit's one-line log, or "nothing to commit" (exit 0: the named paths exist, nothing changed).
# Exit 2: a bad flag, no message, no paths. Exit 1, nothing committed: not in a work tree, detached HEAD,
# a path outside the work tree or the root itself, a `.DS_Store` or an owner's `comments/.draft/`
# among what would be staged, a path git cannot add, every named path skipped (none on disk or in HEAD), `git commit` failing (a
# pre-commit or commit-msg hook; the index stays as it was), --push with no origin, the lock not taken in
# time or lost, the fast-forward refused, the push failed 5 times.
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
SAVED=""; ADD=(); OWNER=(); ITA=(); PRE=""; LANDED=""; NEW=""; KEEP=""
release() {
  trap '' TERM INT HUP   # the cleanup runs to its end
  # only while the lock is ours: HEAD back at PRE (taken back) -> restore; our commit on HEAD or under it (or HEAD moved off
  # PRE mid-commit) -> sync; any other HEAD -> left alone, said
  if [ "${#ADD[@]}" -gt 0 ] && own; then
    local h c=""; h=$(git rev-parse HEAD 2>/dev/null || true)
    if [ -n "$LANDED" ] && [ -n "$NEW" ]; then
      if [ "$h" = "$PRE" ]; then restore || true
      elif git merge-base --is-ancestor "$NEW" HEAD 2>/dev/null; then git reset -q -- "${ADD[@]}" || true; c=$NEW
      else echo "commit-board.sh: HEAD moved to ${h:0:8} during the run, off ${NEW:0:8}; the index left as it is" >&2; fi
    elif [ -n "$PRE" ] && [ "$h" != "$PRE" ]; then git reset -q -- "${ADD[@]}" || true; c=$h; fi
    [ -z "$PUSH" ] || [ -n "$OK" ] || [ -z "$c" ] || echo "commit-board.sh: interrupted: ${c:0:8} committed, not pushed" >&2
  fi
  if own; then rm -rf "$LOCK"; fi; rm -rf "$STAGE" "$LOCK.$$"; [ -n "$KEEP" ] || [ -z "$SAVED" ] || rm -f "$SAVED"
}
trap release EXIT
trap 'exit 143' TERM; trap 'exit 130' INT; trap 'exit 129' HUP   # bash runs these once the foreground git returns; an INT to the pid alone while a child runs is dropped by bash
SAVED=$(mktemp "$(git rev-parse --absolute-git-dir)/lanework-commit-board.saved.XXXXXX")   # per work tree, as the index is; never another run's
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
mine() { own || { echo "commit-board.sh: lost the lock ($LOCK); stopping, nothing more written" >&2; exit 1; }; }

# both <list a> <list b>: the lines in both (newline lists)
both() { [ -n "$1" ] && [ -n "$2" ] && grep -x -F -f <(printf '%s\n' "$2") <<<"$1" || true; }
dirty() { git diff --name-only HEAD; git ls-files --others --exclude-standard; }
# sync: fetch, then fast-forward onto origin/<branch>; stop, naming the files, on a dirty overlap or a diverged branch
sync() {
  [ -n "$HAS_ORIGIN" ] || return 0
  if ! git fetch -q origin 2>"$STAGE/fetch.err"; then
    sed 's/^/  /' "$STAGE/fetch.err" >&2
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
  if [ -z "$STAGED" ]; then echo "nothing to commit"; exit 0; fi
  mine
  LANDED=""; NEW=""; PRE=$(git rev-parse HEAD)   # the EXIT trap syncs the index once HEAD is no longer this (or LANDED)
  [ "$try" -gt 1 ] || save_owner   # once: later tries start from the restored index, and an upstream change to a staged path stops the fast-forward
  GIT_INDEX_FILE="$IDX" git commit -q -F "$STAGE/msg" || { echo "commit-board.sh: git commit failed (a pre-commit or commit-msg hook?); nothing committed, $KEPT" >&2; exit 1; }
  LANDED=1; NEW=$(git rev-parse HEAD)
  sync_index   # before the push: a kill from here on leaves an index that matches HEAD
  [ -n "$PUSH" ] || { OK=1; break; }
  mine
  if git push -q origin "$BRANCH" 2>"$STAGE/push.err"; then OK=1; KEEP=""; break; fi   # pushed: an earlier failed restore's entries are obsolete
  echo "commit-board.sh: push rejected (try $try of 5); un-committing ${NEW:0:8} (ref only, files stay) and retrying" >&2
  sed 's/^/  git: /' "$STAGE/push.err" >&2
  mine
  git update-ref "refs/heads/$BRANCH" "$NEW^" "$NEW"
  if restore; then KEPT="the index restored to what was staged before the run"
  else KEPT="the index for the named paths NOT restored to what was staged before the run (check git status)"; fi
  LANDED=""; PRE=""   # nothing of ours on HEAD; the index is the owner's again
  sleep 1
done
[ "$(git stash list | wc -l | tr -d ' ')" = "$STASH0" ] || echo "commit-board.sh: WARNING: the stash count changed while committing; tell the coordinator" >&2
[ -n "$OK" ] || { echo "commit-board.sh: push failed 5 times; nothing committed, files on disk, $KEPT" >&2; exit 1; }
git log --oneline -1 | cat
