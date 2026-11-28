#!/bin/bash
# move-card.sh: move one card to another lane, stamped by the caller.
# usage: move-card.sh <board> <card-uuid-or-prefix> <lane-title> --model m [--name n] [--session s]
#          [--comment F] [--top|--bottom|--order N] [--clear-waiting]
# The card is found in any lane by its uuid or a lowercase prefix of 8+ characters: exactly one match.
# Rewrites `modified` whole (`at` from the clock, `by` from the caller, any old `by` replaced; a card
# the owner filed has none) and `order`: the lane's max + 1024 (--bottom, the default), or half the
# lane's lowest with --top (lowest - 1024 when that is 0 or less; 1024 in an empty lane), or N with --order (a number: a card put back
# where it was, as start-card.sh's undo does). --clear-waiting
# drops `waiting`; the default keeps it. Every other line stays byte for byte, except that the indented
# continuation lines of a block-form `order`, `modified` or (with --clear-waiting) `waiting` go with their key.
# --comment F posts F through post-comment.sh with the same `by`, only once every refusal below has passed
# (just before the first `mv`); a validator failure after the `mv` leaves it posted. Staged outside the board, then one `mv` of the
# card's folder, then the board's .schema validator on the card (skipped with a note when the board
# has none). Prints the card's new path. No git, no commit.
# Exit 2, nothing written: no model (--model, else CLAUDE_MODEL), a bad flag, fewer than 3 arguments, an id that is not a lowercase uuid or a prefix of 8+ characters, no match or several. Exit 1, nothing written: not a
# board, an unreadable --comment, no such lane, the card already in that lane (a reorder rewrites `order` only), a card folder of that id already in the destination, no frontmatter,
# a triple brace after the restamp, the comment refused. Exit 1 after the `mv`: the validator failed on
# the card, or printed a DEPRECATED line (counts as failure).
# The lease (lanework/references/writes.md § Lease), after the refusals above and before anything is
# written: with CLAUDE_CODE_SESSION_ID set (never --session), `lanework/scripts/lease.sh check`. Held or
# never held: move. Never held and the lane a working lane (lanework/scripts/lib.sh WORKING_LANES: Active, Working): one note on
# stderr, once the card is in, that it went in unstaked; the move as ever (same exit, same stdout): start a card with start-card.sh. Lost: lease.sh posts the Lease lost record; nothing moved, no --comment, exit 3
# (also exit 3 when post-comment.sh reports the lease lost for --comment).
# No session id, or no lanework/scripts/lease.sh beside work (one note on stderr): no check. Another
# check failure: exit 1, nothing written. No release here.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="move-card.sh <board> <card-uuid-or-prefix> <lane-title> --model m [--name n] [--session s] [--comment F] [--top|--bottom|--order N] [--clear-waiting]"
[ $# -ge 3 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; PREFIX="$2"; LANE_TITLE="$3"; shift 3
MODEL=""; NAME="claude"; SESSION=""; COMMENT=""; PLACE=""; CLEAR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --model)   need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)    need_value "$@"; NAME="$2"; shift 2 ;;
    --session) need_value "$@"; SESSION="$2"; shift 2 ;;
    --comment) need_value "$@"; COMMENT="$2"; shift 2 ;;
    --top|--bottom) [ -z "$PLACE" ] || [ "$PLACE" = "$1" ] || { echo "move-card.sh: one of --top, --bottom, --order" >&2; exit 2; }; PLACE="$1"; shift ;;
    --order) need_value "$@"; [ -z "$PLACE" ] || { echo "move-card.sh: one of --top, --bottom, --order" >&2; exit 2; }
      [[ "$2" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { echo "move-card.sh: --order wants a number, got: '$2'" >&2; exit 2; }; PLACE=--order; ORDER="$2"; shift 2 ;;
    --clear-waiting) CLEAR=1; shift ;;
    *) echo "move-card.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model move-card.sh "$USAGE"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
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

if [ "$PLACE" = --order ]; then :
elif [ "$PLACE" = --top ]; then
  LOW=$(low_order "$DEST")
  if [ -z "$LOW" ]; then ORDER=1024
  else ORDER=$(awk -v m="$LOW" 'BEGIN{ if (m > 0) printf "%.15g\n", m/2; else printf "%.15g\n", m-1024 }'); fi
else
  ORDER=$(next_order "$DEST")
fi

LEASE="$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lease.sh"; UNSTAKED=""
if [ -n "${CLAUDE_CODE_SESSION_ID:-}" ] && [ ! -f "$LEASE" ]; then
  echo "move-card.sh: note: no lanework/scripts/lease.sh beside work; the lease is not checked" >&2
elif [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
  rc=0; "$LEASE" check "$BOARD" "$CID" --model "$MODEL" --name "$NAME" >/dev/null || rc=$?
  case $rc in
    0) ;;
    4) ! is_working_lane "$LANE_TITLE" || UNSTAKED=1 ;;   # the note, once the card is in
    3) echo "move-card.sh: this session's lease on ${CID:0:8} is lost (the Lease lost record is on the card); nothing moved" >&2; exit 3 ;;
    *) echo "move-card.sh: lease.sh check failed (exit $rc); nothing moved" >&2; exit 1 ;;
  esac
fi

BY=$(by_of "$NAME" "$MODEL" "$SESSION")

NOW=$(now_utc)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/work-move.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
CARD=$(find_card)   # fresh, in the same command as the write
# frontmatter only: order and modified rewritten whole (block-form continuation lines dropped), waiting dropped on --clear-waiting;
# a missing order or modified is added before the closing ---
LW_O="order: $ORDER" LW_M="modified: {at: $NOW, by: $BY}" awk -v clear="$CLEAR" '   # ENVIRON, not -v: awk -v interprets backslash escapes in a stamp value
  BEGIN { o = ENVIRON["LW_O"]; m = ENVIRON["LW_M"] }
  NR == 1 && $0 == "---" { fm = 1; print; next }
  fm && drop && /^[ \t]/ { next }
  fm { drop = 0 }
  fm && $0 == "---" { if (!so) print o; if (!sm) print m; fm = 0; print; next }
  fm && /^order:/ { print o; so = 1; drop = 1; next }
  fm && /^modified:/ { print m; sm = 1; drop = 1; next }
  fm && clear && /^waiting:/ { drop = 1; next }
  { print }' "$CARD/index.md" > "$STAGE/index.md"
if ! stamp_lines_ok "$STAGE/index.md" order modified; then echo "move-card.sh: triple brace after the restamp; nothing written" >&2; exit 1; fi
[ "$(head -1 "$STAGE/index.md")" = "---" ] || { echo "move-card.sh: $CARD/index.md has no frontmatter; nothing written" >&2; exit 1; }

if [ -n "$COMMENT" ]; then
  rc=0; "$(dirname "${BASH_SOURCE[0]}")/post-comment.sh" "$BOARD" "$CID" --body "$COMMENT" --model "$MODEL" --name "$NAME" ${SESSION:+--session "$SESSION"} >/dev/null || rc=$?
  case $rc in
    0) ;;
    3) echo "move-card.sh: this session's lease on ${CID:0:8} is lost; nothing moved" >&2; exit 3 ;;
    *) echo "move-card.sh: the comment was refused; card not moved" >&2; exit 1 ;;
  esac
fi
mv "$STAGE/index.md" "$CARD/index.md"
mv "$CARD" "$DEST/$CID"
# the note never changes the exit or stdout: a subshell ignoring SIGPIPE, its failure ignored, so a closed or broken stderr costs only
# the note (a `{ ...; } 2>/dev/null` around it would send the note itself to /dev/null)
[ -z "$UNSTAKED" ] || ( trap '' PIPE; echo "move-card.sh: note: ${CID:0:8} went into $LANE_TITLE unstaked: this session holds no lease on it (never-held); start a card with work/scripts/start-card.sh" >&2 ) || true
VAL="$BOARD/.schema/bin/lanework-validate.py"
if [ -f "$VAL" ]; then
  OUT=$(python3 -I "$VAL" "$DEST/$CID/index.md" 2>&1) && ! grep -q DEPRECATED <<<"$OUT" || { printf '%s\n' "$OUT" >&2; echo "move-card.sh: the card fails the board's validator: $DEST/$CID" >&2; exit 1; }
else
  echo "move-card.sh: note: no .schema/bin/lanework-validate.py on the board; card not validated" >&2
fi
sign_board "$BOARD"
printf '%s\n' "$DEST/$CID"
