#!/bin/bash
# settle-question.sh: record a ruling on a question card and move it.
# usage: settle-question.sh <board> <card-uuid> --ruling F [--to settled|parked] \
#          [--record F [--reply <ask-uuid>]] [--model m] [--name n] [--session s]
# Appends `## Ruling` + the --ruling text (templates/ruling.md), drops `waiting`, restamps,
# posts --record as a comment (in reply to --reply), moves the card to the bottom of Settled
# or Parked. Staged outside the board; the card path is re-resolved just before landing.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"

BOARD="${1:?usage: settle-question.sh <board> <card-uuid> --ruling F [...]}"
CID="${2:?usage: settle-question.sh <board> <card-uuid> --ruling F [...]}"
shift 2
TO="settled"; REPLY=""; RULING=""; RECORD=""
MODEL="${CLAUDE_MODEL:-unknown}"; NAME="claude"; SESSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --to)      TO="${2:?}"; shift 2 ;;
    --reply)   REPLY="${2:?}"; shift 2 ;;
    --ruling)  RULING="${2:?}"; shift 2 ;;
    --record)  RECORD="${2:?}"; shift 2 ;;
    --model)   MODEL="${2:?}"; shift 2 ;;
    --name)    NAME="${2:?}"; shift 2 ;;
    --session) SESSION="${2:?}"; shift 2 ;;
    *) echo "settle-question.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
[ -r "${RULING:-}" ] || { echo "settle-question.sh: --ruling must name a readable file" >&2; exit 2; }
[ -z "$RECORD" ] || [ -r "$RECORD" ] || { echo "settle-question.sh: --record must name a readable file" >&2; exit 2; }
case "$TO" in settled) LANE_TITLE=Settled ;; parked) LANE_TITLE=Parked ;; *) echo "settle-question.sh: --to is settled or parked" >&2; exit 2 ;; esac
DEST=$(lane_by_title "$BOARD" "$LANE_TITLE") || { echo "settle-question.sh: no lane titled $LANE_TITLE" >&2; exit 1; }

find_card() { ls -d "$BOARD"/*/"$CID" 2>/dev/null | head -1 || true; }
CARD=$(find_card)
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] || { echo "settle-question.sh: no card $CID on the board" >&2; exit 1; }

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); ORDER=$(next_order "$DEST")
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/discovery-settle.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT

awk -v o="order: $ORDER" -v m="modified: {at: $NOW, by: $BY}" '
  /^---[ \t]*$/ { n++ }
  n==1 && /^waiting:/ { next }
  n==1 && /^order:/ { print o; next }
  n==1 && /^modified:/ { print m; next }
  { print }' "$CARD/index.md" > "$STAGE/index.md"
{ printf '\n## Ruling\n\n'; cat "$RULING"; } >> "$STAGE/index.md"
if grep -q '}}}' "$STAGE/index.md"; then echo "settle-question.sh: triple brace after restamp; aborting" >&2; exit 1; fi

COID=""
if [ -n "$RECORD" ]; then
  COID=$(uuid); mkdir -p "$STAGE/comment"
  comment_file "$STAGE/comment/index.md" "$NOW" "$BY" "$REPLY" < "$RECORD"
fi

CARD=$(find_card)
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] || { echo "settle-question.sh: card $CID moved during settle; nothing written" >&2; exit 1; }
mv "$STAGE/index.md" "$CARD/index.md"
if [ -n "$COID" ]; then mkdir -p "$CARD/comments"; mv "$STAGE/comment" "$CARD/comments/$COID"; fi
if [ "$CARD" != "$DEST/$CID" ]; then mv "$CARD" "$DEST/$CID"; fi

printf 'settled %s -> %s (order %s)\n' "${CID:0:8}" "$LANE_TITLE" "$ORDER"
if [ -n "$COID" ]; then printf 'record comment %s\n' "$COID"; fi
printf 'lanework://%s/%s\n' "$(fm_value "$BOARD/index.md" id)" "$CID"
