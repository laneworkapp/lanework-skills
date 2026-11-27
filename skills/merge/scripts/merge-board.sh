#!/bin/bash
# merge-board.sh: the placement pass over a repo's unmerged board paths, then a one-paragraph report.
# usage: merge-board.sh <repo> [--model <your model>]
# Never commits: the merge commit (or `git rebase --continue`) is the user's.
# Exit 0 = every board path resolved and every touched board validates.
# Exit 1 = a refusal: <repo> is not a git repo, or resolve left something (its exit 1, passed on).
# Exit 2 = usage: no argument, an unknown argument (a first one starting with `-` too), `--model` with no value (nothing run).
# Exit 0 also signs each board the pass touched (lib.sh sign_board): the boards with unmerged paths before it, and the boards with
# staged paths after it (resolve's own validation set). Never on exit 1.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

USAGE="usage: merge-board.sh <repo> [--model <model>]"
[ $# -ge 1 ] || { echo "$USAGE" >&2; exit 2; }
case "$1" in -*) echo "merge-board.sh: unknown argument: $1" >&2; echo "$USAGE" >&2; exit 2 ;; esac
REPO="$1"; shift
MODEL="${LANEWORK_MERGE_MODEL:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --model) [ $# -ge 2 ] || { echo "$USAGE" >&2; exit 2; }; MODEL="$2"; shift 2 ;;
    *) echo "merge-board.sh: unknown argument: $1" >&2; echo "$USAGE" >&2; exit 2 ;;
  esac
done
git -C "$REPO" rev-parse --show-toplevel >/dev/null 2>&1 || { echo "merge-board.sh: not a git repo: $REPO" >&2; exit 1; }
if [ -z "$(git -C "$REPO" config --get merge.lanework.driver || true)" ]; then
  echo "note: the board merge driver is not installed in this clone (scripts/lanework-merge.py install <repo>)."
fi
args=(resolve "$REPO"); [ -n "$MODEL" ] && args+=(--model "$MODEL")
TOP=$(git -C "$REPO" rev-parse --show-toplevel)
# boards_of: the board folder (the first segment ending in .lanework, never the last) of each NUL-separated repo path on stdin, one per line
boards_of() { tr '\0' '\n' | awk -F/ '{ for (i = 1; i < NF; i++) if ($i ~ /\.lanework$/) { b = $1; for (j = 2; j <= i; j++) b = b "/" $j; print b; break } }'; }
BEFORE=$(git -C "$TOP" diff --name-only -z --diff-filter=U | boards_of || true)
python3 "$HERE/lanework-merge.py" "${args[@]}" </dev/null
{ printf '%s\n' "$BEFORE"; git -C "$TOP" diff --cached --name-only -z | boards_of || true; } | sort -u | while IFS= read -r b; do
  [ -z "$b" ] || sign_board "$TOP/$b"
done
