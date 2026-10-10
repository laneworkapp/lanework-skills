#!/bin/bash
# claim-ticket.sh: claim a Frontier ticket for this session, before any work on it.
# usage: claim-ticket.sh <board> <card-uuid> --model m [--name n] [--session s]
# Moves the card from Frontier to the bottom of Working (fresh order, `modified` rewritten whole)
# and posts "**Claimed** by <name>". Refuses with exit 1 when the card is not in Frontier
# (claimed by another session, blocked, resolved). Staged outside the board; the card path is
# re-resolved just before landing, and a card that left Frontier meanwhile is refused.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"

BOARD="${1:?usage: claim-ticket.sh <board> <card-uuid> --model m [...]}"
CID="${2:?usage: claim-ticket.sh <board> <card-uuid> --model m [...]}"
shift 2
MODEL=""; NAME="claude"; SESSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --model)   MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)    NAME="${2:?--name needs a value}"; shift 2 ;;
    --session) SESSION="${2:?--session needs a value}"; shift 2 ;;
    *) echo "claim-ticket.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model claim-ticket.sh "claim-ticket.sh <board> <card-uuid> --model m [--name n] [--session s]"
[ -f "$BOARD/index.md" ] || { echo "claim-ticket.sh: not a board: $BOARD" >&2; exit 1; }
[[ "$CID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || { echo "claim-ticket.sh: not a lowercase card uuid: $CID" >&2; exit 1; }
FRONTIER=$(lane_by_title "$BOARD" Frontier) || { echo "claim-ticket.sh: no Frontier lane on $BOARD" >&2; exit 1; }
DEST=$(lane_by_title "$BOARD" Working) || { echo "claim-ticket.sh: no Working lane on $BOARD" >&2; exit 1; }

where() { local d; d=$(ls -d "$BOARD"/*/"$CID" 2>/dev/null | head -1 || true); [ -n "$d" ] && strip_quotes "$(fm_value "$(dirname "$d")/index.md" title)"; }
refuse_unless_frontier() {
  [ -f "$FRONTIER/$CID/index.md" ] && return 0
  local l; l=$(where || true)
  if [ -n "$l" ]; then echo "claim-ticket.sh: ${CID:0:8} is in $l, not Frontier: take another ticket" >&2
  else echo "claim-ticket.sh: no card $CID on the board" >&2; fi
  exit 1
}
refuse_unless_frontier

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); ORDER=$(next_order "$DEST")
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/plan-claim.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
awk -v o="order: $ORDER" -v m="modified: {at: $NOW, by: $BY}" '
  /^---[ \t]*$/ { n++ }
  n==1 && /^order:/ { print o; next }
  n==1 && /^modified:/ { print m; next }
  { print }' "$FRONTIER/$CID/index.md" > "$STAGE/index.md"
if grep -q '}}}' "$STAGE/index.md"; then echo "claim-ticket.sh: triple brace after restamp; aborting" >&2; exit 1; fi
COID=$(uuid); mkdir -p "$STAGE/comment"
printf '**Claimed** by %s%s.\n' "$NAME" "${SESSION:+, session $SESSION}" | comment_file "$STAGE/comment/index.md" "$NOW" "$BY"

refuse_unless_frontier
mv "$STAGE/index.md" "$FRONTIER/$CID/index.md"
mv "$FRONTIER/$CID" "$DEST/$CID"
mkdir -p "$DEST/$CID/comments"; mv "$STAGE/comment" "$DEST/$CID/comments/$COID"

printf 'claimed %s -> Working (order %s)\n' "${CID:0:8}" "$ORDER"
printf 'lanework://%s/%s\n' "$(fm_value "$BOARD/index.md" id)" "$CID"
