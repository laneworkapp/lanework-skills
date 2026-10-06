#!/bin/bash
# merge-board.sh: the placement pass over a repo's unmerged board paths, then a one-paragraph report.
# usage: merge-board.sh <repo> [--model <your model>]
# Never commits: the merge commit (or `git rebase --continue`) is the user's.
# Exit 0 = every board path resolved and every touched board validates.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO="${1:?usage: merge-board.sh <repo> [--model <model>]}"; shift
MODEL="${LANEWORK_MERGE_MODEL:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --model) MODEL="${2:?--model needs a value}"; shift 2 ;;
    *) echo "merge-board.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
git -C "$REPO" rev-parse --show-toplevel >/dev/null 2>&1 || { echo "merge-board.sh: not a git repo: $REPO" >&2; exit 1; }
if [ -z "$(git -C "$REPO" config --get merge.lanework.driver || true)" ]; then
  echo "note: the board merge driver is not installed in this clone (scripts/lanework-merge.py install <repo>)."
fi
args=(resolve "$REPO"); [ -n "$MODEL" ] && args+=(--model "$MODEL")
python3 "$HERE/lanework-merge.py" "${args[@]}" </dev/null
