#!/bin/bash
# found-discovery-board.sh: cold-start a discovery board.
# usage: found-discovery-board.sh "<path>/<Topic> Discovery.lanework" ["Title"] --model m [--name n]
# lanework's found-board.sh with templates/board.md + templates/lanes.md;
# --labels k,... adds kinds to round (which is always written); repeats accumulate, an empty list exits 2. --model passes through (required: found-board.sh exits 2 without it or CLAUDE_MODEL).
# {{topic}} = the title minus a trailing " Discovery".
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOARD="${1:?usage: found-discovery-board.sh <path>/<Topic> Discovery.lanework [title] --model m [--name n]}"
shift
TITLE=""
if [ $# -gt 0 ] && [[ "$1" != --* ]]; then TITLE="$1"; shift; fi
[ -n "$TITLE" ] || TITLE=$(basename "$BOARD" .lanework)
# round is always present: a caller's --labels adds kinds to it (round first, deduped)
. "$HERE/../../lanework/scripts/lib.sh"
ARGS=(); EXTRA=""; HAVE_EXTRA=""
while [ $# -gt 0 ]; do
  if [ "$1" = --labels ]; then EXTRA="$(merge_kinds "$EXTRA" "$HAVE_EXTRA" "${2?--labels needs a kind list}")"; HAVE_EXTRA=1; shift 2; else ARGS+=("$1"); shift; fi
done
LABELS=round
if [ -n "$HAVE_EXTRA" ]; then   # an empty or blank name stays in the list, so found-board.sh rejects it
  REST="$EXTRA,"
  while [ -n "$REST" ]; do k="${REST%%,*}"; REST="${REST#*,}"; [ "$k" = round ] || LABELS="$LABELS,$k"; done
fi
exec "$HERE/../../lanework/scripts/found-board.sh" "$BOARD" \
  --index "$HERE/../templates/board.md" --lanes "$HERE/../templates/lanes.md" \
  --title "$TITLE" --labels "$LABELS" --var topic="$(flat_str "${TITLE% Discovery}")" ${ARGS[@]+"${ARGS[@]}"}
