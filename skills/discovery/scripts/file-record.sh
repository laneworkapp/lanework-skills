#!/bin/bash
# file-record.sh: file an ADR or PDR card into Decisions from a question's ruling, before it settles.
# usage: file-record.sh <board> <question-card-uuid> --record ADR|PDR --title t --body F \
#          [--from <lane title>] [--supersedes <record-uuid>]... --model m [--name n] [--session s]
# Card frontmatter from templates/record.md (flattened `Record` and `accepted` status labels), body = line 1 linking the question
# (link text: its citation, else its title), then --body. On a board whose app draws `cite-as` (lib.sh `cite_enabled`) the card gets `cite-as: ADR<n>` or
# `PDR<n>` (lanework/references/writes.md), a bare title, and a second printed line `cite ADR<n>`; on any other board the title is "<ADR|PDR>: <t>". Lands at the
# bottom of Decisions (its card-defaults labels unioned in), staged outside the board. Prints the card's lanework:// link: put it
# in the ruling (templates/ruling.md). Run before settle-question.sh: the question must still be
# in Asked (a settled card is never edited), or in the --from lane (plan: Working). No waiting, no comments.
# --supersedes <uuid> (repeatable): each must be a card in Decisions; the new card gets one `supersedes`
# relation per target (relations/<uuid>/index.md). Nothing is written to the old card. Any bad target: exit 1, nothing written.
# Exit 2, nothing written: usage (a missing positional, flag or flag value, an unknown flag, --record not ADR or PDR, no --title, an unreadable --body, no model (--model, else CLAUDE_MODEL)).
# Exit 1, nothing written: not a board, no Decisions or --from lane, a bad question uuid or one not in the --from lane, a bad --supersedes, a brace in the frontmatter.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"

USAGE='file-record.sh <board> <question-card-uuid> --record ADR|PDR --title t --body F [--from <lane title>] [--supersedes <record-uuid>]... --model m [--name n] [--session s]'
[ $# -ge 2 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; QID="$2"
shift 2
KIND=""; TITLE=""; BODY_FILE=""; FROM="Asked"
MODEL=""; NAME="claude"; SESSION=""; SUPERSEDES=()
while [ $# -gt 0 ]; do
  case "$1" in
    --record)  need_value "$@"; KIND="$2"; shift 2 ;;
    --title)   need_value "$@"; TITLE="$2"; shift 2 ;;
    --body)    need_value "$@"; BODY_FILE="$2"; shift 2 ;;
    --from)    need_value "$@"; FROM="$2"; shift 2 ;;
    --supersedes) need_value "$@"; SUPERSEDES+=("$2"); shift 2 ;;
    --model)   need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)    [ $# -ge 2 ] || need_value "$@"; NAME="$2"; shift 2 ;;
    --session) need_value "$@"; SESSION="$2"; shift 2 ;;
    *) echo "file-record.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model file-record.sh "file-record.sh <board> <question-uuid> --record ADR|PDR --title t --body F --model m [...]"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
case "$KIND" in ADR) RANK=1 ;; PDR) RANK=2 ;; *) echo "file-record.sh: --record is ADR or PDR" >&2; exit 2 ;; esac
[ -n "$TITLE" ] || { echo "file-record.sh: --title is required" >&2; exit 2; }
[ -n "$BODY_FILE" ] && [ -r "$BODY_FILE" ] || { echo "file-record.sh: --body must name a readable file" >&2; exit 2; }
[ -f "$BOARD/index.md" ] || { echo "file-record.sh: not a board: $BOARD" >&2; exit 1; }

DEC=$(lane_by_title "$BOARD" Decisions) || { echo "file-record.sh: no Decisions lane on $BOARD (add it, with the record and status label kinds: templates/lanes.md, templates/board.md)" >&2; exit 1; }
[[ "$QID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || { echo "file-record.sh: not a lowercase card uuid: $QID" >&2; exit 1; }
SRC=$(lane_by_title "$BOARD" "$FROM") || { echo "file-record.sh: no $FROM lane on $BOARD" >&2; exit 1; }
for S in ${SUPERSEDES[@]+"${SUPERSEDES[@]}"}; do
  [[ "$S" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] && [ -f "$DEC/$S/index.md" ] || { echo "file-record.sh: --supersedes $S is not a lowercase full uuid of a card in Decisions" >&2; exit 1; }
done
QCARD="$SRC/$QID"
[ -f "$QCARD/index.md" ] || { echo "file-record.sh: $QID is not a card in $FROM (file the record before it leaves $FROM)" >&2; exit 1; }
BOARD_ID=$(fm_value "$BOARD/index.md" id)
QTITLE=$(card_ref "$QCARD/index.md")

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); CARD_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/discovery-record.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
C="$STAGE/$CARD_ID"; mkdir -p "$C"

if cite_enabled "$BOARD"; then   # the citation is scanned later (stamp_cite), just before the card is written
  CITE=CITEPENDING; CTITLE=$(title_str "$TITLE"); frontmatter_of "$TEMPLATES/record.md" > "$STAGE/fm.md"
else
  CITE=""; CTITLE="$KIND: $(title_str "$TITLE")"; frontmatter_of "$TEMPLATES/record.md" | grep -v '^cite-as:' > "$STAGE/fm.md"
fi
render "$STAGE/fm.md" kind "$KIND" cite "$CITE" rank "$RANK" title "$CTITLE" order "$(next_order "$DEC")" stamp "{at: $NOW, by: $BY}" > "$STAGE/fm.out"
if ! stamp_lines_ok "$STAGE/fm.out" created modified; then echo "file-record.sh: triple brace in the frontmatter; aborting" >&2; exit 1; fi
union_lane_defaults "$DEC" "$BOARD" "$STAGE/fm.out"
compact_fm "$STAGE/fm.out"
if cite_enabled "$BOARD"; then CITE=$(stamp_cite "$STAGE/fm.out" "$BOARD" "$KIND"); fi   # scanned here, after the slow steps
{
  cat "$STAGE/fm.out"
  printf 'Question: [%s](lanework://%s/%s)\n\n' "$QTITLE" "$BOARD_ID" "$QID"
  cat "$BODY_FILE"
} > "$C/index.md"

for S in ${SUPERSEDES[@]+"${SUPERSEDES[@]}"}; do
  RD="$C/relations/$(uuid)"; mkdir -p "$RD"
  printf -- '---\nschema: 1\nkind: relation\ncreated: {at: %s, by: %s}\nrel: supersedes\nto: lanework://%s/%s\n---\n' "$NOW" "$BY" "$BOARD_ID" "$S" > "$RD/index.md"
done

DEC=$(lane_by_title "$BOARD" Decisions)
mv "$C" "$DEC/$CARD_ID"
printf 'lanework://%s/%s\n' "$BOARD_ID" "$CARD_ID"
if [ -n "$CITE" ]; then printf 'cite %s\n' "$CITE"; fi
