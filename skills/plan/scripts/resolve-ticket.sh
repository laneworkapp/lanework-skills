#!/bin/bash
# resolve-ticket.sh: record a ticket's resolution and move it; unblock what it was holding.
# usage: resolve-ticket.sh <board> <card-uuid> --resolution F [--to resolved|out-of-scope] \
#          --model m [--name n] [--session s]
# Appends `## Resolution` + the --resolution text (templates/resolution.md), drops `waiting`,
# restamps, moves the card to the bottom of Resolved (card must be in Working) or Out of scope
# (card in Frontier, Blocked or Working). Then, only for resolved: every Blocked ticket whose
# `## Depends on` links are all in Resolved moves to the bottom of Frontier (fresh order,
# `modified` rewritten whole), one `unblocked T<n>` line each. Staged outside the board; each
# card path is re-resolved just before landing. Prints the resolved card's link.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"

BOARD="${1:?usage: resolve-ticket.sh <board> <card-uuid> --resolution F [...]}"
CID="${2:?usage: resolve-ticket.sh <board> <card-uuid> --resolution F [...]}"
shift 2
TO="resolved"; RESOLUTION=""
MODEL=""; NAME="claude"; SESSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --to)         TO="${2:?--to needs a value}"; shift 2 ;;
    --resolution) RESOLUTION="${2:?--resolution needs a file}"; shift 2 ;;
    --model)      MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)       NAME="${2:?--name needs a value}"; shift 2 ;;
    --session)    SESSION="${2:?--session needs a value}"; shift 2 ;;
    *) echo "resolve-ticket.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model resolve-ticket.sh "resolve-ticket.sh <board> <card-uuid> --resolution F --model m [...]"
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

card_of() { ls -d "$BOARD"/*/"$1" 2>/dev/null | head -1 || true; }
lane_of() { local d; d=$(card_of "$1"); [ -n "$d" ] && strip_quotes "$(fm_value "$(dirname "$d")/index.md" title)"; }
deps_of() {  # deps_of <card index.md>: card uuids linked under "## Depends on"
  awk '/^## Depends on[ \t]*$/ { f=1; next } f && /^## / { exit } f' "$1" |
    grep -oE 'lanework://[^/)]+/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | sed 's#.*/##' || true
}
restamp() {  # restamp <src> <order> <dest>: fresh order + modified, waiting dropped
  awk -v o="order: $2" -v m="modified: {at: $NOW, by: $BY}" '
    /^---[ \t]*$/ { n++ }
    n==1 && /^waiting:/ { next }
    n==1 && /^order:/ { print o; next }
    n==1 && /^modified:/ { print m; next }
    { print }' "$1" > "$3"
  if grep -q '}}}' "$3"; then echo "resolve-ticket.sh: triple brace after restamp; aborting" >&2; exit 1; fi
}

CARD=$(card_of "$CID")
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] || { echo "resolve-ticket.sh: no card $CID on the board" >&2; exit 1; }
HERE_LANE=$(lane_of "$CID")
case " $FROM " in *" $HERE_LANE "*) ;; *)
  if [ "$TO" = resolved ]; then echo "resolve-ticket.sh: ${CID:0:8} is in $HERE_LANE, not Working: claim it first (claim-ticket.sh)" >&2
  else echo "resolve-ticket.sh: ${CID:0:8} is in $HERE_LANE: only a Frontier, Blocked or Working ticket goes out of scope" >&2; fi
  exit 1 ;;
esac

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); ORDER=$(next_order "$DEST")
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/plan-resolve.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
restamp "$CARD/index.md" "$ORDER" "$STAGE/index.md"
{ printf '\n## Resolution\n\n'; cat "$RESOLUTION"; } >> "$STAGE/index.md"

CARD=$(card_of "$CID")
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] && [ "$(lane_of "$CID")" = "$HERE_LANE" ] || { echo "resolve-ticket.sh: card $CID moved during resolve; nothing written" >&2; exit 1; }
mv "$STAGE/index.md" "$CARD/index.md"
[ "$CARD" = "$DEST/$CID" ] || mv "$CARD" "$DEST/$CID"
printf 'resolved %s -> %s (order %s)\n' "${CID:0:8}" "$LANE_TITLE" "$ORDER"

# ---- unblock: Blocked tickets whose every dependency is now Resolved -> bottom of Frontier ----
if [ "$TO" = resolved ]; then
  BLOCKED=$(lane_by_title "$BOARD" Blocked || true); FRONTIER=$(lane_by_title "$BOARD" Frontier || true)
  if [ -n "$BLOCKED" ] && [ -n "$FRONTIER" ]; then
    while IFS= read -r f; do
      deps=$(deps_of "$f"); [ -n "$deps" ] || continue
      all=1; for d in $deps; do [ "$(lane_of "$d" || true)" = Resolved ] || { all=0; break; }; done
      [ "$all" -eq 1 ] || continue
      bid=$(basename "$(dirname "$f")")
      restamp "$f" "$(next_order "$FRONTIER")" "$STAGE/u.md"
      [ -f "$BLOCKED/$bid/index.md" ] || continue
      mv "$STAGE/u.md" "$BLOCKED/$bid/index.md"; mv "$BLOCKED/$bid" "$FRONTIER/$bid"
      t=$(strip_quotes "$(fm_value "$FRONTIER/$bid/index.md" title)")
      printf 'unblocked %s\n' "${t%%:*}"
    done < <(for g in "$BLOCKED"/*/index.md; do [ -f "$g" ] && printf '%s\t%s\n' "$(fm_value "$g" order)" "$g"; done | sort -n | cut -f2-)
  fi
fi
printf 'lanework://%s/%s\n' "$BOARD_ID" "$CID"
