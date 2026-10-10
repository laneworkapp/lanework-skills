#!/bin/bash
# found-discovery-board.sh: cold-start a discovery board.
# usage: found-discovery-board.sh "<path>/<Topic> Discovery.lanework" ["Title"] --model m [--name n]
# lanework's found-board.sh with templates/board.md + templates/lanes.md;
# --model passes through (required: found-board.sh exits 2 without it or CLAUDE_MODEL).
# {{topic}} = the title minus a trailing " Discovery".
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOARD="${1:?usage: found-discovery-board.sh <path>/<Topic> Discovery.lanework [title] --model m [--name n]}"
shift
TITLE=""
if [ $# -gt 0 ] && [[ "$1" != --* ]]; then TITLE="$1"; shift; fi
[ -n "$TITLE" ] || TITLE=$(basename "$BOARD" .lanework)
exec "$HERE/../../lanework/scripts/found-board.sh" "$BOARD" \
  --index "$HERE/../templates/board.md" --lanes "$HERE/../templates/lanes.md" \
  --title "$TITLE" --var topic="${TITLE% Discovery}" "$@"
