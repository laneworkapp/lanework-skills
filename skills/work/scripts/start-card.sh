#!/bin/bash
# start-card.sh: start a work order in one call: stake the card's lease, move it into the board's working lane, post its START.
# usage: start-card.sh <board> <card-uuid> --comment F --model m [--name n] [--session s]
# F = the START record (references/writing.md § START), a bare body: its first non-blank line opens with START
# (lanework/scripts/lib.sh START_ERE), not a shaping start. The working lane: the first of lib.sh WORKING_LANES the board has (Active). Steps, each by the
# existing script: lanework/scripts/lease.sh stake (lanework/references/writes.md § Lease); then move-card.sh into that lane with
# --comment F, or, for a card already there (a re-start), post-comment.sh --body F. The holder is CLAUDE_CODE_SESSION_ID, never
# --session (a stamp label). Prints "started <id8> in <lane>" and the card's lanework:// link; a takeover's `prior:` line first.
# Exit 2, nothing written: usage (a missing positional, flag or flag value, no --comment, an unknown flag), no model (--model, else
# CLAUDE_MODEL), a stamp value lib.sh stamp_args_ok refuses.
# Exit 1, nothing written: not a board, not a lowercase card uuid, no such card or several, an unreadable --comment or one that is
# no start record, no working lane, a plan board (a Frontier lane: plan/scripts/claim-ticket.sh takes its tickets), no CLAUDE_CODE_SESSION_ID or no
# CLAUDE_PID (no session, no lease), no lanework/scripts/lease.sh beside work; the stake refused (another session holds the card;
# lease.sh names it on stderr; a takeover notice it posted stays).
# Exit 3: this session's lease on the card is lost (lease.sh stake, move-card.sh or post-comment.sh said so; the Lease lost record is on the card).
# Exit 1 after the stake: the move or the record failed (that script's message on stderr). A lease this call staked is then released, so a
# failed start leaves no lease; one this session held before the call is kept. Landed = the card in the working lane after this call's
# move (move-card.sh failing only at its validator, after its `mv`) or the record posted (a re-start): the lease is kept.
# A stake over a lapsed lease waits for the takeover notice (2 min): give the call a timeout over that.
set -euo pipefail
HERE="$(dirname "${BASH_SOURCE[0]}")"
. "$HERE/../../lanework/scripts/lib.sh"
USAGE='start-card.sh <board> <card-uuid> --comment F --model m [--name n] [--session s]'
[ $# -ge 2 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; CID="$2"; shift 2
MODEL=""; NAME="claude"; SESSION=""; COMMENT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --comment) need_value "$@"; COMMENT="$2"; shift 2 ;;
    --model)   need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)    [ $# -ge 2 ] || need_value "$@"; NAME="$2"; shift 2 ;;
    --session) need_value "$@"; SESSION="$2"; shift 2 ;;
    *) echo "start-card.sh: unknown argument: $1" >&2; echo "usage: $USAGE" >&2; exit 2 ;;
  esac
done
require_model start-card.sh "$USAGE"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
[ -n "$COMMENT" ] || { echo "start-card.sh: no --comment: the START record" >&2; echo "usage: $USAGE" >&2; exit 2; }
[ -f "$BOARD/index.md" ] || { echo "start-card.sh: not a board: $BOARD" >&2; exit 1; }
[[ "$CID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || { echo "start-card.sh: not a lowercase card uuid: $CID" >&2; exit 1; }
[ -r "$COMMENT" ] || { echo "start-card.sh: cannot read --comment $COMMENT" >&2; exit 1; }
FIRST=$(awk 'NF { sub(/\r$/, ""); print; exit }' "$COMMENT")
LOWER=$(printf '%s' "$FIRST" | tr 'A-Z' 'a-z')
if ! [[ $FIRST =~ $START_ERE ]] || [[ $LOWER =~ $SHAPE_ERE ]]; then
  echo "start-card.sh: --comment is no START record (its first line opens with START:, work/references/writing.md § START); nothing written" >&2; exit 1
fi
! lane_by_title "$BOARD" Frontier >/dev/null || { echo "start-card.sh: a plan board: claim a ticket with plan/scripts/claim-ticket.sh; nothing written" >&2; exit 1; }
DEST=$(working_lane "$BOARD") || { echo "start-card.sh: no working lane ($(printf '%s' "$WORKING_LANES" | paste -sd, - | sed 's/,/, /g')) on $BOARD; nothing written" >&2; exit 1; }
LANE=$(strip_quotes "$(fm_value "$DEST/index.md" title)")
N=$(ls "$BOARD"/*/"$CID"/index.md 2>/dev/null | grep -c . || true)
[ "$N" = 1 ] || { echo "start-card.sh: $N cards $CID on the board; need exactly one" >&2; exit 1; }

LEASE="$HERE/../../lanework/scripts/lease.sh"
[ -n "${CLAUDE_CODE_SESSION_ID:-}" ] || { echo "start-card.sh: no CLAUDE_CODE_SESSION_ID: no session id, no lease, no start (--session is only a stamp label); nothing written" >&2; exit 1; }
[ -n "${CLAUDE_PID:-}" ] || { echo "start-card.sh: no CLAUDE_PID: the lease's timer needs the session's process; nothing written" >&2; exit 1; }
[ -f "$LEASE" ] || { echo "start-card.sh: no lanework/scripts/lease.sh beside work: no lease, no start; nothing written" >&2; exit 1; }

# a lease this session held before the call (a re-start, a renewal) is never released by a failure here
HOLDER=$("$LEASE" list "$BOARD" | awk -F'\t' -v c="$CID" '$1 == c { print $2 }')
FRESH=""; STAKING=""; LANDED=""; ALREADY=""
[ ! -f "$DEST/$CID/index.md" ] || ALREADY=1
case "$HOLDER" in *"($CLAUDE_CODE_SESSION_ID)") ;; *) FRESH=1 ;; esac
# release what this call staked unless the start landed. A stake that never landed leaves nothing of this session's: release then
# refuses another session's lease (exit 1), a lost one (3) or a usage it shares with the stake (2), writing nothing; quiet, exit code unchanged
cleanup() {
  [ -n "$FRESH" ] && [ -n "$STAKING" ] && [ -z "$LANDED" ] || return 0
  if [ -z "$ALREADY" ] && [ -f "$DEST/$CID/index.md" ]; then return 0; fi   # moved in (failed only at the validator): landed
  local r=0; "$LEASE" release "$BOARD" "$CID" --model "$MODEL" --name "$NAME" >/dev/null 2>&1 || r=$?
  case $r in 0|1|2|3) ;; *) echo "start-card.sh: the lease on ${CID:0:8} was not released (exit $r): lanework/scripts/lease.sh release by hand" >&2 ;; esac
}
trap cleanup EXIT
STAKING=1   # before the stake, so a call ended while the stake runs still releases what it left
rc=0; OUT=$("$LEASE" stake "$BOARD" "$CID" --model "$MODEL" --name "$NAME") || rc=$?
case $rc in
  0) ;;
  3) echo "start-card.sh: this session's lease on ${CID:0:8} is lost; nothing else written" >&2; exit 3 ;;
  *) echo "start-card.sh: ${CID:0:8} not started: lease.sh stake exit $rc; nothing else written" >&2; exit 1 ;;
esac
grep '^prior: ' <<<"$OUT" || true   # a takeover: the thread's latest START or Lease lost record, read before working

rc=0
if [ -n "$ALREADY" ]; then
  "$HERE/post-comment.sh" "$BOARD" "$CID" --body "$COMMENT" --model "$MODEL" --name "$NAME" ${SESSION:+--session "$SESSION"} >/dev/null || rc=$?
else
  "$HERE/move-card.sh" "$BOARD" "$CID" "$LANE" --comment "$COMMENT" --model "$MODEL" --name "$NAME" ${SESSION:+--session "$SESSION"} >/dev/null || rc=$?
fi
case $rc in
  0) LANDED=1 ;;
  3) echo "start-card.sh: this session's lease on ${CID:0:8} is lost" >&2; exit 3 ;;
  *) STEP=move; [ -z "$ALREADY" ] || STEP=record; echo "start-card.sh: ${CID:0:8}: the $STEP failed (exit $rc)" >&2; exit 1 ;;
esac
printf 'started %s in %s\n' "${CID:0:8}" "$LANE"
printf 'lanework://%s/%s\n' "$(fm_value "$BOARD/index.md" id)" "$CID"
