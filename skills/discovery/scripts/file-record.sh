#!/bin/bash
# file-record.sh: file an ADR or PDR card into Decisions from a settled ruling.
# usage: file-record.sh <board> <question-card-uuid> --record ADR|PDR --title t --body F \
#          [--model m] [--name n] [--session s]
# Card frontmatter from templates/record.md (title "<ADR|PDR>: <t>", flattened `Record` and
# `accepted` status labels), body = line 1 linking the question, then --body. Lands at the
# bottom of Decisions, staged outside the board. Prints the card's lanework:// link: put it
# in the ruling (templates/ruling.md). Run before settle-question.sh: the question must still be
# in Asked (a settled card is never edited). No waiting, no comments.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"

BOARD="${1:?usage: file-record.sh <board> <question-uuid> --record ADR|PDR --title t --body F [...]}"
QID="${2:?usage: file-record.sh <board> <question-uuid> --record ADR|PDR --title t --body F [...]}"
shift 2
KIND=""; TITLE=""; BODY_FILE=""
MODEL="${CLAUDE_MODEL:-unknown}"; NAME="claude"; SESSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --record)  KIND="${2:?--record needs ADR or PDR}"; shift 2 ;;
    --title)   TITLE="${2:?--title needs text}"; shift 2 ;;
    --body)    BODY_FILE="${2:?--body needs a file}"; shift 2 ;;
    --model)   MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)    NAME="${2:?--name needs a value}"; shift 2 ;;
    --session) SESSION="${2:?--session needs a value}"; shift 2 ;;
    *) echo "file-record.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
case "$KIND" in ADR) RANK=1 ;; PDR) RANK=2 ;; *) echo "file-record.sh: --record is ADR or PDR" >&2; exit 1 ;; esac
[ -n "$TITLE" ] || { echo "file-record.sh: --title is required" >&2; exit 1; }
[ -n "$BODY_FILE" ] && [ -r "$BODY_FILE" ] || { echo "file-record.sh: --body must name a readable file" >&2; exit 1; }
[ -f "$BOARD/index.md" ] || { echo "file-record.sh: not a board: $BOARD" >&2; exit 1; }

DEC=$(lane_by_title "$BOARD" Decisions) || { echo "file-record.sh: no Decisions lane on $BOARD (add it, with the record and status label kinds: templates/lanes.md, templates/board.md)" >&2; exit 1; }
[[ "$QID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || { echo "file-record.sh: not a lowercase card uuid: $QID" >&2; exit 1; }
ASKED=$(lane_by_title "$BOARD" Asked) || { echo "file-record.sh: no Asked lane on $BOARD" >&2; exit 1; }
QCARD="$ASKED/$QID"
[ -f "$QCARD/index.md" ] || { echo "file-record.sh: $QID is not a question in Asked (file the record before settling)" >&2; exit 1; }
BOARD_ID=$(fm_value "$BOARD/index.md" id)
QTITLE=$(strip_quotes "$(fm_value "$QCARD/index.md" title)" | perl -pe 's/\\(.)/$1/g; s/([\\\[\]])/\\$1/g')
CTITLE="${TITLE//$'\n'/ }"; CTITLE="${CTITLE//$'\r'/ }"; CTITLE="${CTITLE//\\/\\\\}"; CTITLE="${CTITLE//\"/\\\"}"

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); CARD_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/discovery-record.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
C="$STAGE/$CARD_ID"; mkdir -p "$C"

frontmatter_of "$TEMPLATES/record.md" > "$STAGE/fm.md"
render "$STAGE/fm.md" kind "$KIND" rank "$RANK" title "$CTITLE" order "$(next_order "$DEC")" stamp "{at: $NOW, by: $BY}" > "$STAGE/fm.out"
if grep -q '}}}' "$STAGE/fm.out"; then echo "file-record.sh: triple brace in the frontmatter; aborting" >&2; exit 1; fi
{
  cat "$STAGE/fm.out"
  printf 'Question: [%s](lanework://%s/%s)\n\n' "$QTITLE" "$BOARD_ID" "$QID"
  cat "$BODY_FILE"
} > "$C/index.md"

DEC=$(lane_by_title "$BOARD" Decisions)
mv "$C" "$DEC/$CARD_ID"
printf 'lanework://%s/%s\n' "$BOARD_ID" "$CARD_ID"
