#!/bin/bash
# file-card.sh: file one new card at the bottom of a lane.
# usage: file-card.sh <board> <lane-title> <title> --body F --model m [--name n] [--session s] [--label Text[:kind]]...
# F = a bare body, no frontmatter. Writes `kind: card`, the quoted title, `order` from next_order
# (1024 in an empty lane: no glob over the lane's cards), `created` and `modified` from the clock
# with the caller's `by`, each --label (union_labels --strict: `Text` is a free label, `Text:kind` is stamped
# from the board's config.labels), then the lane's card-defaults labels (union_lane_defaults), in the compact
# form. Staged outside the board, one `mv` in, then the board's .schema validator on the card
# (skipped with a note when the board has none). Prints the card's path.
# No founding comment (post one with post-comment.sh), no git. `waiting` is written by hand.
# Exit 1, nothing written: not a board, no such lane, unreadable body or one with frontmatter,
# a malformed card-defaults, a --label with an undefined kind or two values of one `single` kind. Exit 1 after the `mv`: the validator failed on the card.
# Exit 2, nothing written: no model, no --body, no title, a bad flag.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="file-card.sh <board> <lane-title> <title> --body F --model m [--name n] [--session s] [--label Text[:kind]]..."
[ $# -ge 3 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; LANE_TITLE="$2"; TITLE="$3"; shift 3
MODEL=""; NAME="claude"; SESSION=""; BODY=""; LABELS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --body)    need_value "$@"; BODY="$2"; shift 2 ;;
    --model)   need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)    need_value "$@"; NAME="$2"; shift 2 ;;
    --session) need_value "$@"; SESSION="$2"; shift 2 ;;
    --label)   need_value "$@"; LABELS+=("$2"); shift 2 ;;
    *) echo "file-card.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model file-card.sh "$USAGE"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
[ -n "$BODY" ] || { echo "file-card.sh: no --body" >&2; echo "usage: $USAGE" >&2; exit 2; }
[ -n "$TITLE" ] || { echo "file-card.sh: empty title" >&2; echo "usage: $USAGE" >&2; exit 2; }
[ -f "$BOARD/index.md" ] || { echo "file-card.sh: not a board: $BOARD" >&2; exit 1; }
[ -r "$BODY" ] || { echo "file-card.sh: cannot read --body $BODY" >&2; exit 1; }
[ "$(head -1 "$BODY")" != "---" ] || { echo "file-card.sh: --body is a bare body: no frontmatter" >&2; exit 1; }
LANE=$(lane_by_title "$BOARD" "$LANE_TITLE") || { echo "file-card.sh: no lane \"$LANE_TITLE\" on $BOARD" >&2; exit 1; }

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); CARD_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/work-card.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
C="$STAGE/$CARD_ID"; mkdir -p "$C"
printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\norder: %s\ncreated:  {at: %s, by: %s}\nmodified: {at: %s, by: %s}\n---\n' \
  "$(title_str "$TITLE")" "$(next_order "$LANE")" "$NOW" "$BY" "$NOW" "$BY" > "$STAGE/fm.out"
[ ${#LABELS[@]} -eq 0 ] || union_labels --strict "$STAGE/fm.out" "$BOARD" "${LABELS[@]}" || { echo "file-card.sh: a --label failed; nothing written" >&2; exit 1; }
union_lane_defaults "$LANE" "$BOARD" "$STAGE/fm.out"
stamp_lines_ok "$STAGE/fm.out" created modified || { echo "file-card.sh: a brace in the stamp (--model, --name or --session); nothing written" >&2; exit 1; }
compact_fm "$STAGE/fm.out"
{ cat "$STAGE/fm.out"; cat "$BODY"; } > "$C/index.md"

LANE=$(lane_by_title "$BOARD" "$LANE_TITLE") || { echo "file-card.sh: lane \"$LANE_TITLE\" went away; nothing written" >&2; exit 1; }
mv "$C" "$LANE/$CARD_ID"
VAL="$BOARD/.schema/bin/lanework-validate.py"
if [ -f "$VAL" ]; then
  OUT=$(python3 -I "$VAL" "$LANE/$CARD_ID/index.md" 2>&1) && ! grep -q DEPRECATED <<<"$OUT" || { printf '%s\n' "$OUT" >&2; echo "file-card.sh: the card fails the board's validator: $LANE/$CARD_ID" >&2; exit 1; }
else
  echo "file-card.sh: note: no .schema/bin/lanework-validate.py on the board; card not validated" >&2
fi
printf '%s\n' "$LANE/$CARD_ID"
