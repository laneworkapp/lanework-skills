#!/bin/bash
# frontier.sh: print a plan board's live tickets; warn on drift. Read-only.
# usage: frontier.sh <board>
# Prints Frontier tickets in order (the top is next), then Blocked tickets each with the
# dependencies not yet Resolved, then Working tickets (`waiting` marked). Warns on stderr when
# a lane disagrees with its tickets' dependencies: a Blocked ticket with every dependency
# Resolved, a Frontier ticket with one open, a dependency pointing at a missing card or at an
# Out of scope one. Always exits 0 on a board.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"

BOARD="${1:?usage: frontier.sh <board>}"
[ -f "$BOARD/index.md" ] || { echo "frontier.sh: not a board: $BOARD" >&2; exit 1; }
BOARD_ID=$(fm_value "$BOARD/index.md" id)

card_of() { ls -d "$BOARD"/*/"$1" 2>/dev/null | head -1 || true; }
lane_of() { local d; d=$(card_of "$1"); [ -n "$d" ] && strip_quotes "$(fm_value "$(dirname "$d")/index.md" title)"; }
title_of() { strip_quotes "$(fm_value "$1/index.md" title)" | perl -pe 's/\\(.)/$1/g'; }
deps_of() {
  awk '/^## Depends on[ \t]*$/ { f=1; next } f && /^## / { exit } f' "$1" |
    grep -oE 'lanework://[^/)]+/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | sed 's#.*/##' || true
}
cards_in() {  # cards_in <lane title>: card dirs in order
  local lane g; lane=$(lane_by_title "$BOARD" "$1") || return 0
  for g in "$lane"/*/index.md; do [ -f "$g" ] && printf '%s\t%s\n' "$(fm_value "$g" order)" "$(dirname "$g")"; done | sort -n | cut -f2-
}
warn() { echo "frontier.sh: drift: $*" >&2; }

for LANE in Frontier Blocked Working; do
  echo "== $LANE"
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    id=$(basename "$c"); t=$(title_of "$c")
    w=""; [ -n "$(fm_value "$c/index.md" waiting)" ] && w="  (waiting)"
    printf '%s  [%s](lanework://%s/%s)%s\n' "$t" "${id:0:8}" "$BOARD_ID" "$id" "$w"
    open=(); n=0
    for d in $(deps_of "$c/index.md"); do
      n=$((n+1)); l=$(lane_of "$d" || true)
      if [ -z "$l" ]; then warn "$t depends on a missing card $d"; open+=("missing ${d:0:8}"); continue; fi
      [ "$l" = "Out of scope" ] && warn "$t depends on $(title_of "$(card_of "$d")"), which is Out of scope: rule it out too, or drop the dependency"
      [ "$l" = Resolved ] || open+=("$(title_of "$(card_of "$d")") ($l)")
    done
    if [ "$LANE" = Blocked ]; then
      for o in ${open[@]+"${open[@]}"}; do printf '    waits on %s\n' "$o"; done
      [ "${#open[@]}" -gt 0 ] || warn "$t is Blocked but $([ "$n" -gt 0 ] && echo 'every dependency is Resolved' || echo 'names no dependency'): move it to Frontier"
    fi
    if [ "$LANE" = Frontier ] && [ "${#open[@]}" -gt 0 ]; then warn "$t is on the Frontier with a dependency open: ${open[*]}"; fi
  done < <(cards_in "$LANE")
done
exit 0
