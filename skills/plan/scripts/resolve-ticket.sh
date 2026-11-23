#!/bin/bash
# resolve-ticket.sh: record a ticket's resolution and move it; unblock what it was holding.
# usage: resolve-ticket.sh <board> <card-uuid> --resolution F [--to resolved|out-of-scope] \
#          --model m [--name n] [--session s]
# Appends `## Resolution` + the --resolution text (templates/resolution.md), drops `waiting` and `claimed` (on every resolve, held lease or not),
# restamps, moves the card to the bottom of Resolved (card must be in Working) or Out of scope
# (card in Frontier, Blocked or Working). Then, only for resolved: every Blocked ticket with a dependency (a `depends-on` relation, deps.sh)
# and every one in Resolved moves to the bottom of Frontier (fresh order,
# `modified` rewritten whole, `waiting` dropped like the resolved card's), one `unblocked <name>` line each (its citation; a card with none: the `T<n>` of a legacy `T<n>: ` title, else the title). Staged outside the board; each
# card path is re-resolved just before landing. Prints `resolved <id> -> <lane> (order <n>)` first, then the `unblocked` lines, then the resolved card's link.
# The lease (lanework/references/writes.md § Lease), after the refusals above and before anything is written: with
# CLAUDE_CODE_SESSION_ID set (never --session), `lanework/scripts/lease.sh check`. Held: resolve, the write above
# (it already dropped `claimed`), then `lease.sh release` once, which stops the timer. Lost: lease.sh posts the Lease lost
# record; exit 1, nothing else written. Never held here, or no session id: a card with no lease (or a voided one) resolves
# as before; another session's lease, live or lapsed, is exit 1, nothing written: stake it first (a lapsed one is taken
# over). Another check failure: exit 1, nothing written. No lanework/scripts/lease.sh beside plan: one note, no check.
# Exit 2, nothing written: usage (a missing positional, flag or flag value, an unknown flag, no --resolution file, a bad --to, no model (--model, else CLAUDE_MODEL)).
# Exit 1 after the card landed: the release failed; lease.sh release by hand.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
. "$(dirname "${BASH_SOURCE[0]}")/deps.sh"

USAGE='resolve-ticket.sh <board> <card-uuid> --resolution F [--to resolved|out-of-scope] --model m [--name n] [--session s]'
[ $# -ge 2 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; CID="$2"
shift 2
TO="resolved"; RESOLUTION=""
MODEL=""; NAME="claude"; SESSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --to)         need_value "$@"; TO="$2"; shift 2 ;;
    --resolution) need_value "$@"; RESOLUTION="$2"; shift 2 ;;
    --model)      need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)       [ $# -ge 2 ] || need_value "$@"; NAME="$2"; shift 2 ;;
    --session)    need_value "$@"; SESSION="$2"; shift 2 ;;
    *) echo "resolve-ticket.sh: unknown argument: $1" >&2; echo "usage: $USAGE" >&2; exit 2 ;;
  esac
done
require_model resolve-ticket.sh "resolve-ticket.sh <board> <card-uuid> --resolution F --model m [...]"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
[ -r "${RESOLUTION:-}" ] || { echo "resolve-ticket.sh: --resolution must name a readable file" >&2; exit 2; }
case "$TO" in
  resolved)     LANE_TITLE=Resolved; FROM="Working" ;;
  out-of-scope) LANE_TITLE="Out of scope"; FROM="Frontier Blocked Working" ;;
  *) echo "resolve-ticket.sh: --to is resolved or out-of-scope" >&2; exit 2 ;;
esac
[ -f "$BOARD/index.md" ] || { echo "resolve-ticket.sh: not a board: $BOARD" >&2; exit 1; }
[[ "$CID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || { echo "resolve-ticket.sh: not a lowercase card uuid: $CID" >&2; exit 1; }
DEST=$(lane_by_title "$BOARD" "$LANE_TITLE") || { echo "resolve-ticket.sh: no lane titled $LANE_TITLE" >&2; exit 1; }
BOARD_ID=$(fm_value "$BOARD/index.md" id)

restamp() {  # restamp <src> <order> <dest> [claimed]: fresh order + modified, waiting dropped, and claimed with "claimed"
  LW_O="order: $2" LW_M="modified: {at: $NOW, by: $BY}" awk -v cl="${4:-}" '   # ENVIRON, not -v: awk -v interprets backslash escapes in a stamp value
    BEGIN { o = ENVIRON["LW_O"]; m = ENVIRON["LW_M"] }
    /^---[ \t]*$/ { n++ }
    n==1 && drop && /^[ \t]/ { next }          # its block lines, where the compact form opened it out
    { drop = 0 }
    n==1 && /^waiting:/ { drop = 1; next }
    n==1 && cl == "claimed" && /^claimed:/ { drop = 1; next }
    n==1 && /^order:/ { print o; next }
    n==1 && /^modified:/ { print m; next }
    { print }' "$1" > "$3"
  if ! stamp_lines_ok "$3" order modified; then echo "resolve-ticket.sh: triple brace after restamp; aborting" >&2; exit 1; fi
}

CARD=$(card_of "$BOARD" "$CID" || true)
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] || { echo "resolve-ticket.sh: no card $CID on the board" >&2; exit 1; }
HERE_LANE=$(lane_of "$BOARD" "$CID")
case " $FROM " in *" $HERE_LANE "*) ;; *)
  if [ "$TO" = resolved ]; then echo "resolve-ticket.sh: ${CID:0:8} is in $HERE_LANE, not Working: claim it first (claim-ticket.sh)" >&2
  else echo "resolve-ticket.sh: ${CID:0:8} is in $HERE_LANE: only a Frontier, Blocked or Working ticket goes out of scope" >&2; fi
  exit 1 ;;
esac

LEASE="$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lease.sh"; HELD=""
if [ ! -f "$LEASE" ]; then
  echo "resolve-ticket.sh: note: no lanework/scripts/lease.sh beside plan; the lease is not checked" >&2
else
  rc=4
  if [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then rc=0; "$LEASE" check "$BOARD" "$CID" --model "$MODEL" --name "$NAME" >/dev/null || rc=$?; fi
  case $rc in
    0) HELD=1 ;;
    3) echo "resolve-ticket.sh: this session's lease on ${CID:0:8} is lost (the Lease lost record is on the card); nothing written" >&2; exit 1 ;;
    4) # never held here: another session's lease (list: uuid, holder, time, live | lapsed | voided, title) is not this resolve's
      ROW=$("$LEASE" list "$BOARD" | awk -F'\t' -v c="$CID" '$1 == c && ($4 == "live" || $4 == "lapsed") { print $2 " (" $4 ")" }')
      [ -z "$ROW" ] || { echo "resolve-ticket.sh: ${CID:0:8} is leased by $ROW: not this session's; nothing written. Stake it first: lanework/scripts/lease.sh stake" >&2; exit 1; } ;;
    *) echo "resolve-ticket.sh: lease.sh check failed (exit $rc); nothing written" >&2; exit 1 ;;
  esac
fi

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); ORDER=$(next_order "$DEST")
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/plan-resolve.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
restamp "$CARD/index.md" "$ORDER" "$STAGE/index.md" claimed
{ printf '\n## Resolution\n\n'; cat "$RESOLUTION"; } >> "$STAGE/index.md"

CARD=$(card_of "$BOARD" "$CID" || true)
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] && [ "$(lane_of "$BOARD" "$CID")" = "$HERE_LANE" ] || { echo "resolve-ticket.sh: card $CID moved during resolve; nothing written" >&2; exit 1; }
mv "$STAGE/index.md" "$CARD/index.md"
[ "$CARD" = "$DEST/$CID" ] || mv "$CARD" "$DEST/$CID"
printf 'resolved %s -> %s (order %s)\n' "${CID:0:8}" "$LANE_TITLE" "$ORDER"
# the card landed without claimed: release finds no lease there, stops the timer and forgets the card, writing nothing (no loss)
RC=0
if [ -n "$HELD" ]; then
  "$LEASE" release "$BOARD" "$CID" --model "$MODEL" --name "$NAME" >/dev/null \
    || { RC=1; echo "resolve-ticket.sh: ${CID:0:8} resolved, but lease.sh release failed: release by hand" >&2; }
fi

# ---- unblock: Blocked tickets whose every dependency is now Resolved -> bottom of Frontier ----
if [ "$TO" = resolved ]; then
  BLOCKED=$(lane_by_title "$BOARD" Blocked || true); FRONTIER=$(lane_by_title "$BOARD" Frontier || true)
  if [ -n "$BLOCKED" ] && [ -n "$FRONTIER" ]; then
    while IFS= read -r f; do
      deps=$(deps_of "$BOARD" "$(dirname "$f")"); [ -n "$deps" ] || continue
      all=1; while IFS= read -r d; do [ "$(lane_of "$BOARD" "$d" || true)" = Resolved ] || { all=0; break; }; done <<<"$deps"
      [ "$all" -eq 1 ] || continue
      bid=$(basename "$(dirname "$f")")
      restamp "$f" "$(next_order "$FRONTIER")" "$STAGE/u.md"
      [ -f "$BLOCKED/$bid/index.md" ] || continue
      mv "$STAGE/u.md" "$BLOCKED/$bid/index.md"; mv "$BLOCKED/$bid" "$FRONTIER/$bid"
      t=$(cite_of "$FRONTIER/$bid/index.md")
      if [ -z "$t" ]; then
        t=$(strip_quotes "$(fm_value "$FRONTIER/$bid/index.md" title)")
        if [[ "$t" =~ ^T[0-9]+:\  ]]; then t="${t%%:*}"; fi
      fi
      printf 'unblocked %s\n' "$t"
    done < <(for g in "$BLOCKED"/*/index.md; do [ -f "$g" ] && printf '%s\t%s\n' "$(fm_value "$g" order)" "$g"; done | sort -n | cut -f2-)
  fi
fi
printf 'lanework://%s/%s\n' "$BOARD_ID" "$CID"
exit "$RC"
