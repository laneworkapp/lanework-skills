#!/bin/bash
# claim-ticket.sh: claim a Frontier ticket for this session, before any work on it.
# usage: claim-ticket.sh <board> <card-uuid> --model m [--name n] [--session s]
# Stakes the card's lease (lanework/scripts/lease.sh stake, lanework/references/writes.md § Lease) while it is still in
# Frontier, then moves it to the bottom of Working (fresh order, `modified` rewritten whole, `claimed` carried as the stake
# left it) and posts "**Claimed** by <name>". The holder is CLAUDE_CODE_SESSION_ID, never --session (a stamp label).
# Exit 1, nothing written: the card not in Frontier (claimed by another session, blocked, resolved); no
# CLAUDE_CODE_SESSION_ID or no CLAUDE_PID (no session, no lease); no lanework/scripts/lease.sh beside plan; the stake
# refused or lost (lease.sh names the holder on stderr; a takeover notice it posted stays). After the stake, the card
# leaving Frontier, the lease no longer this session's, or any other abort, a TERM during the stake included: exit 1
# (a signal: its own code), the lease just staked released. Once the card is in Working the claim has landed: an abort
# keeps the lease, at worst without the Claimed comment. A SIGKILL before that strands the stake: the same session's next
# claim recovers it.
# Staged outside the board, from the card as the stake left it; the card path is re-resolved just before landing.
# A stake over a lapsed lease waits for the takeover notice (2 min): give the call a timeout over that.
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

LEASE="$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lease.sh"
[ -n "${CLAUDE_CODE_SESSION_ID:-}" ] || { echo "claim-ticket.sh: no CLAUDE_CODE_SESSION_ID: no session id, no lease, no claim (--session is only a stamp label); nothing written" >&2; exit 1; }
[ -n "${CLAUDE_PID:-}" ] || { echo "claim-ticket.sh: no CLAUDE_PID: the lease's timer needs the session's process; nothing written" >&2; exit 1; }
[ -f "$LEASE" ] || { echo "claim-ticket.sh: no lanework/scripts/lease.sh beside plan: no lease, no claim; nothing written" >&2; exit 1; }

where() { local d; d=$(ls -d "$BOARD"/*/"$CID" 2>/dev/null | head -1 || true); [ -n "$d" ] && strip_quotes "$(fm_value "$(dirname "$d")/index.md" title)"; }
refuse_unless_frontier() {
  [ -f "$FRONTIER/$CID/index.md" ] && return 0
  local l; l=$(where || true)
  if [ -n "$l" ]; then echo "claim-ticket.sh: ${CID:0:8} is in $l, not Frontier: take another ticket" >&2
  else echo "claim-ticket.sh: no card $CID on the board" >&2; fi
  exit 1
}
refuse_unless_frontier

# a lease this session held before the claim (staked by hand) is renewed by the stake, and never released by an abort here
HOLDER=$("$LEASE" list "$BOARD" | awk -F'\t' -v c="$CID" '$1 == c { print $2 }')
STAKED=""; DONE=""; STAGE=""
cleanup() {
  [ -z "$STAGE" ] || rm -rf "$STAGE"
  # release whatever the stake left. A stake that never landed leaves nothing of this session's: release then refuses
  # another session's lease (exit 1), a lost one (exit 3) or a usage it shares with the stake (exit 2), writing nothing and
  # posting nothing; quiet, exit code unchanged
  if [ -n "$STAKED" ] && [ -z "$DONE" ]; then
    local r=0; "$LEASE" release "$BOARD" "$CID" --model "$MODEL" --name "$NAME" >/dev/null 2>&1 || r=$?
    case $r in 0|1|2|3) ;; *) echo "claim-ticket.sh: the lease on ${CID:0:8} was not released (exit $r): lanework/scripts/lease.sh release by hand" >&2 ;; esac
  fi
}
trap cleanup EXIT
# marked before the stake, so a claim ended while the stake runs (a signal waits for it) still releases what it left
case "$HOLDER" in *"($CLAUDE_CODE_SESSION_ID)") ;; *) STAKED=1 ;; esac
rc=0; OUT=$("$LEASE" stake "$BOARD" "$CID" --model "$MODEL" --name "$NAME") || rc=$?
[ "$rc" -eq 0 ] || { echo "claim-ticket.sh: ${CID:0:8} not claimed: lease.sh stake exit $rc; nothing else written" >&2; exit 1; }
grep '^prior: ' <<<"$OUT" || true   # a takeover: the thread's latest START or Lease lost record, read before working
refuse_unless_frontier

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); ORDER=$(next_order "$DEST")
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/plan-claim.XXXXXX")
# order and modified rewritten in place; every other line (claimed included, flow or block) copied as the stake left it
awk -v o="order: $ORDER" -v m="modified: {at: $NOW, by: $BY}" '
  /^---[ \t]*$/ { n++ }
  n==1 && /^order:/ { print o; next }
  n==1 && /^modified:/ { print m; next }
  { print }' "$FRONTIER/$CID/index.md" > "$STAGE/index.md"
if grep -q '}}}' "$STAGE/index.md"; then echo "claim-ticket.sh: triple brace after restamp; aborting" >&2; exit 1; fi
COID=$(uuid); mkdir -p "$STAGE/comment"
printf '**Claimed** by %s%s.\n' "$NAME" "${SESSION:+, session $SESSION}" | comment_file "$STAGE/comment/index.md" "$NOW" "$BY"

refuse_unless_frontier
rc=0; "$LEASE" check "$BOARD" "$CID" --model "$MODEL" --name "$NAME" >/dev/null || rc=$?
if [ "$rc" -ne 0 ]; then
  [ "$rc" -ne 3 ] || STAKED=""   # lost: lease.sh posted the Lease lost record; nothing left to release
  echo "claim-ticket.sh: ${CID:0:8}'s lease is no longer this session's (lease.sh check exit $rc); nothing moved" >&2; exit 1
fi
mv "$STAGE/index.md" "$FRONTIER/$CID/index.md"
mv "$FRONTIER/$CID" "$DEST/$CID"
DONE=1   # landed: in Working with its lease; an abort from here keeps the lease, at worst without the Claimed comment
mkdir -p "$DEST/$CID/comments"; mv "$STAGE/comment" "$DEST/$CID/comments/$COID"

printf 'claimed %s -> Working (order %s)\n' "${CID:0:8}" "$ORDER"
printf 'lanework://%s/%s\n' "$(fm_value "$BOARD/index.md" id)" "$CID"
