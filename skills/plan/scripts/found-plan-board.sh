#!/bin/bash
# found-plan-board.sh: cold-start a plan board.
# usage: found-plan-board.sh "<path>/<Topic> Plan.lanework" ["Title"] --model m [--labels k,...] [--name n]
# lanework's found-board.sh with templates/board.md + templates/lanes.md. The template writes its own
# ticket, record and status kinds; --labels adds catalog kinds after ticket (repeats accumulate, an
# empty list exits 2, a kind outside the catalog exits 2). No --labels: the {{label_entries}} slot is
# dropped from a copy of the template staged outside the board. --model passes through (required:
# found-board.sh exits 2 without it or CLAUDE_MODEL). {{topic}} = the title minus a trailing " Plan".
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOARD="${1:?usage: found-plan-board.sh <path>/<Topic> Plan.lanework [title] --model m [--labels k,...] [--name n]}"
shift
TITLE=""
if [ $# -gt 0 ] && [[ "$1" != --* ]]; then TITLE="$1"; shift; fi
[ -n "$TITLE" ] || TITLE=$(basename "$BOARD" .lanework)
. "$HERE/../../lanework/scripts/lib.sh"
ARGS=(); HAVE_LABELS=""
while [ $# -gt 0 ]; do
  if [ "$1" = --labels ]; then ARGS+=(--labels "${2?--labels needs a kind list}"); HAVE_LABELS=1; shift 2; else ARGS+=("$1"); shift; fi
done
INDEX="$HERE/../templates/board.md"
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/plan-found.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
if [ -z "$HAVE_LABELS" ]; then sed 's/{{label_entries}}//' "$INDEX" > "$STAGE/board.md"; INDEX="$STAGE/board.md"; fi
"$HERE/../../lanework/scripts/found-board.sh" "$BOARD" \
  --index "$INDEX" --lanes "$HERE/../templates/lanes.md" \
  --title "$TITLE" --var topic="$(flat_str "${TITLE% Plan}")" ${ARGS[@]+"${ARGS[@]}"}
