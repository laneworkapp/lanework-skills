#!/bin/bash
# move-card.sh: move one card to another lane, stamped by the caller.
# usage: move-card.sh <board> <card-uuid-or-prefix> <lane-title> --model m [--name n] [--session s]
#          [--comment F] [--top|--bottom] [--clear-waiting]
# The card is found in any lane by its uuid or a lowercase prefix of 8+ characters: exactly one match.
# Rewrites `modified` whole (`at` from the clock, `by` from the caller, any old `by` replaced; a card
# the owner filed has none) and `order`: the lane's max + 1024 (--bottom, the default), or half the
# lane's lowest with --top (lowest - 1024 when that is 0 or less; 1024 in an empty lane). --clear-waiting
# drops `waiting`; the default keeps it. Every other line stays byte for byte. --comment F posts F
# through post-comment.sh with the same `by` first. Staged outside the board, then one `mv` of the
# card's folder, then the board's .schema validator on the card (skipped with a note when the board
# has none). Prints the card's new path. No git, no commit.
# Exit 2, nothing written: no model, a bad flag, no match or several. Exit 1, nothing written: not a
# board, no such lane, the card already in that lane (a reorder rewrites `order` only), the comment
# refused. Exit 1 after the `mv`: the validator failed on the card.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="move-card.sh <board> <card-uuid-or-prefix> <lane-title> --model m [--name n] [--session s] [--comment F] [--top|--bottom] [--clear-waiting]"
[ $# -ge 3 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; PREFIX="$2"; LANE_TITLE="$3"; shift 3
MODEL=""; NAME="claude"; SESSION=""; COMMENT=""; PLACE=""; CLEAR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --model)   MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)    NAME="${2:?--name needs a value}"; shift 2 ;;
    --session) SESSION="${2:?--session needs a value}"; shift 2 ;;
    --comment) COMMENT="${2:?--comment needs a file}"; shift 2 ;;
    --top|--bottom) [ -z "$PLACE" ] || [ "$PLACE" = "$1" ] || { echo "move-card.sh: --top or --bottom, not both" >&2; exit 2; }; PLACE="$1"; shift ;;
    --clear-waiting) CLEAR=1; shift ;;
    *) echo "move-card.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model move-card.sh "$USAGE"
[[ "$PREFIX" =~ ^[0-9a-f-]{8,36}$ ]] || { echo "move-card.sh: want a lowercase card uuid or a prefix of 8+ characters, got: '$PREFIX'" >&2; exit 2; }
[ -f "$BOARD/index.md" ] || { echo "move-card.sh: not a board: $BOARD" >&2; exit 1; }
[ -z "$COMMENT" ] || [ -r "$COMMENT" ] || { echo "move-card.sh: cannot read --comment $COMMENT" >&2; exit 1; }

# find_card: the one card folder whose name starts with the prefix, in any lane; exit 2 unless exactly one
find_card() {
  local lane c hits=() n
  for lane in "$BOARD"/*/; do
    lane="${lane%/}"
    [ -f "$lane/index.md" ] && [ "$(fm_value "$lane/index.md" kind)" = lane ] || continue
    for c in "$lane/$PREFIX"*/; do
      c="${c%/}"; [ -f "$c/index.md" ] && hits+=("$c")
    done
  done
  n=${#hits[@]}
  [ "$n" -eq 1 ] || { echo "move-card.sh: $n cards match '$PREFIX' on the board; need exactly one" >&2; exit 2; }
  printf '%s' "${hits[0]}"
}
# low_order <lane>: the lowest numeric order among the lane's cards, empty when none
low_order() {
  local f o min=""
  for f in "$1"/*/index.md; do
    [ -f "$f" ] || continue
    o=$(fm_value "$f" order)
    case "$o" in ''|*[!0-9.-]*) continue ;; esac
    if [ -z "$min" ] || awk -v a="$o" -v b="$min" 'BEGIN{exit !(a<b)}'; then min="$o"; fi
  done
  printf '%s' "$min"
}

CARD=$(find_card); CID=$(basename "$CARD")
DEST=$(lane_by_title "$BOARD" "$LANE_TITLE") || { echo "move-card.sh: no lane \"$LANE_TITLE\" on $BOARD" >&2; exit 1; }
[ "$(dirname "$CARD")" != "$DEST" ] || { echo "move-card.sh: ${CID:0:8} is already in $LANE_TITLE; a reorder rewrites order only" >&2; exit 1; }
[ ! -e "$DEST/$CID" ] || { echo "move-card.sh: $DEST/$CID already exists" >&2; exit 1; }

if [ "$PLACE" = --top ]; then
  LOW=$(low_order "$DEST")
  if [ -z "$LOW" ]; then ORDER=1024
  else ORDER=$(awk -v m="$LOW" 'BEGIN{ if (m > 0) printf "%.15g\n", m/2; else printf "%.15g\n", m-1024 }'); fi
else
  ORDER=$(next_order "$DEST")
fi

BY=$(by_of "$NAME" "$MODEL" "$SESSION")
if [ -n "$COMMENT" ]; then
  "$(dirname "${BASH_SOURCE[0]}")/post-comment.sh" "$BOARD" "$CID" --body "$COMMENT" --model "$MODEL" --name "$NAME" ${SESSION:+--session "$SESSION"} >/dev/null \
    || { echo "move-card.sh: the comment was refused; card not moved" >&2; exit 1; }
fi

NOW=$(now_utc)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/work-move.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
CARD=$(find_card)   # fresh, in the same command as the write
# frontmatter only: order and modified rewritten whole (block-form continuation lines dropped), waiting dropped on --clear-waiting;
# a missing order or modified is added before the closing ---
awk -v o="order: $ORDER" -v m="modified: {at: $NOW, by: $BY}" -v clear="$CLEAR" '
  NR == 1 && $0 == "---" { fm = 1; print; next }
  fm && drop && /^[ \t]/ { next }
  fm { drop = 0 }
  fm && $0 == "---" { if (!so) print o; if (!sm) print m; fm = 0; print; next }
  fm && /^order:/ { print o; so = 1; drop = 1; next }
  fm && /^modified:/ { print m; sm = 1; drop = 1; next }
  fm && clear && /^waiting:/ { drop = 1; next }
  { print }' "$CARD/index.md" > "$STAGE/index.md"
if grep -q '}}}' "$STAGE/index.md"; then echo "move-card.sh: triple brace after the restamp; nothing written" >&2; exit 1; fi
[ "$(head -1 "$STAGE/index.md")" = "---" ] || { echo "move-card.sh: $CARD/index.md has no frontmatter; nothing written" >&2; exit 1; }

mv "$STAGE/index.md" "$CARD/index.md"
mv "$CARD" "$DEST/$CID"
VAL="$BOARD/.schema/bin/lanework-validate.py"
if [ -f "$VAL" ]; then
  OUT=$(python3 -I "$VAL" "$DEST/$CID/index.md" 2>&1) && ! grep -q DEPRECATED <<<"$OUT" || { printf '%s\n' "$OUT" >&2; echo "move-card.sh: the card fails the board's validator: $DEST/$CID" >&2; exit 1; }
else
  echo "move-card.sh: note: no .schema/bin/lanework-validate.py on the board; card not validated" >&2
fi
printf '%s\n' "$DEST/$CID"
