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
# T as its last paragraph only when --trailer gives one. --push pushes <branch> to origin; a rejected
# push un-commits (the branch ref only, files stay on disk) and retries from the fetch, up to 5 tries:
# safe only because the lock serialises commits. --push pushes the branch, so earlier unpushed commits
# on it go too. Without --push nothing leaves the machine.
# Never stashes (warns if the stash count changed), never `add -A` without paths, never rebases.
# Closing `git reset -q -- <paths>` syncs the real index for the named paths only: anything the owner
# had staged under them is unstaged, everything else they staged stays staged.
# Prints the new commit's one-line log, or "nothing to commit".
# Exit 2: a bad flag, no message, no paths. Exit 1, nothing committed: not in a work tree, detached HEAD,
# a path outside the work tree, the root itself or a glob, a `.DS_Store` or an owner's `comments/.draft/`
# among what would be staged, a path git cannot add, --push with no origin, the lock not taken in
# time or lost, the fast-forward refused, the push failed 5 times.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE='commit-board.sh [--push] [--trailer T] "<msg>" <paths...>'
PUSH=""; TRAILER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --push)    PUSH=1; shift ;;
    --trailer) [ $# -ge 2 ] && [ -n "$2" ] || { echo "commit-board.sh: --trailer needs a value" >&2; echo "usage: $USAGE" >&2; exit 2; }; TRAILER="$2"; shift 2 ;;
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
  abs=$(python3 -I -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$p")
  case "$abs" in
    "$TOP") echo "commit-board.sh: $p is the whole work tree; name the board files" >&2; exit 1 ;;
    "$TOP"/*) ;;
    *) echo "commit-board.sh: $p is outside the work tree $TOP" >&2; exit 1 ;;
  esac
  case "$p" in *[\*\?\[]*) echo "commit-board.sh: refusing $p: a glob; name each path" >&2; exit 1 ;; esac
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
release() { if own; then rm -rf "$LOCK"; fi; rm -rf "$STAGE" "$LOCK.$$"; }
trap release EXIT
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
    echo "commit-board.sh: $BRANCH and origin/$BRANCH have diverged ($(git rev-list --count "$base..HEAD") local, $(git rev-list --count "$base..$UP") incoming); changed on both sides:" >&2
    both "$(printf '%s\n' "$ours" | sort -u)" "$in" | sed 's/^/  /' >&2; exit 1
  fi
}

STASH0=$(git stash list | wc -l | tr -d ' ')
{ printf '%s\n' "$MSG"; [ -z "$TRAILER" ] || printf '\n%s\n' "$TRAILER"; } > "$STAGE/msg"
OK=""; NEW=""
for try in 1 2 3 4 5; do
  sync
  IDX="$STAGE/index"; rm -f "$IDX"
  GIT_INDEX_FILE="$IDX" git read-tree HEAD
  ADD=()   # a named path gone from disk and never committed (a card filed and moved since HEAD) has nothing to add
  for r in "${REL[@]}"; do
    if [ -e "$r" ] || [ -L "$r" ] || [ -n "$(GIT_INDEX_FILE="$IDX" git ls-files -- "$r")" ]; then ADD+=("$r")
    elif [ "$try" -eq 1 ]; then echo "commit-board.sh: note: $r is neither on disk nor in HEAD; skipped" >&2; fi
  done
  [ "${#ADD[@]}" -gt 0 ] || { echo "nothing to commit"; exit 0; }
  GIT_INDEX_FILE="$IDX" git add -A -- "${ADD[@]}" 2>"$STAGE/add.err" || { sed 's/^/  /' "$STAGE/add.err" >&2; echo "commit-board.sh: git cannot add those paths; nothing committed" >&2; exit 1; }
  STAGED=$(GIT_INDEX_FILE="$IDX" git diff --cached --name-only HEAD)
  BAD=$(grep -E '(^|/)\.DS_Store$|(^|/)comments/\.draft(/|$)' <<<"$STAGED" || true)
  [ -z "$BAD" ] || { echo "commit-board.sh: refusing, these would be committed (.DS_Store, or an owner's unposted draft); name the files instead:" >&2; sed 's/^/  /' <<<"$BAD" >&2; exit 1; }
  if [ -z "$STAGED" ]; then echo "nothing to commit"; exit 0; fi
  mine
  GIT_INDEX_FILE="$IDX" git commit -q -F "$STAGE/msg"
  NEW=$(git rev-parse HEAD)
  [ -n "$PUSH" ] || { OK=1; break; }
  mine
  if git push -q origin "$BRANCH" 2>"$STAGE/push.err"; then OK=1; break; fi
  echo "commit-board.sh: push rejected (try $try of 5); un-committing ${NEW:0:8} (ref only, files stay) and retrying" >&2
  sed 's/^/  git: /' "$STAGE/push.err" >&2
  mine
  git update-ref "refs/heads/$BRANCH" "$NEW^" "$NEW"
  sleep 1
done
git reset -q -- "${ADD[@]}" 2>/dev/null || echo "commit-board.sh: warning: could not sync the real index for the named paths (git reset)" >&2
[ "$(git stash list | wc -l | tr -d ' ')" = "$STASH0" ] || echo "commit-board.sh: WARNING: the stash count changed while committing; tell the coordinator" >&2
[ -n "$OK" ] || { echo "commit-board.sh: push failed 5 times; nothing committed, files on disk" >&2; exit 1; }
git log --oneline -1 | cat
