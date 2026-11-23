#!/bin/bash
# read-board.sh: print a board in reading order: lanes by `order`, cards by `order` within each.
# usage: read-board.sh "<path>/<Name>.lanework"
# Missing `order` sorts last and prints as 999999999. A card id prints as its first 8 characters. Dot-folders (.schema, .log, .trash) are skipped.
# Titles and ids only, a card's `cite-as` before its title as `<citation>: <title>`; read the bodies next (references/reading.md).
# A card with a `priority` label ends its line with `  priority: <text> (<rank>)` (its lowest rank; `(-)` = no readable rank); a card with none
# prints as before. Cards still print by `order`, never re-sorted by priority; apply the pick order (references/reading.md) from the ranks.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
# Exit: exit 0 read; exit 1 not a board; exit 2 usage (no argument, or an unknown argument).
[ $# -eq 1 ] && [ "${1#-}" = "$1" ] || { echo "usage: read-board.sh <board>" >&2; exit 2; }
BOARD="$1"
[ -f "$BOARD/index.md" ] || { echo "read-board.sh: not a board: $BOARD" >&2; exit 1; }

# one Python start for the whole board: `<card path>\t<text>\t<rank>` per card with a priority
PRI=$(priorities_of "$BOARD"/*/*/index.md 2>/dev/null || true)
pri_suffix() { [ -n "$PRI" ] || return 0; printf '%s\n' "$PRI" | awk -F'\t' -v id="$1" '{ n = split($1, a, "/"); if (a[n-1] == id) { printf "  priority: %s (%s)", $2, $3; exit } }'; }
title_of() { strip_quotes "$(fm_value "$1" title)"; }
card_title_of() { local c; c=$(cite_of "$1"); if [ -n "$c" ]; then printf '%s: %s' "$c" "$(title_of "$1")"; else title_of "$1"; fi; }
printf '%s  [%s]\n' "$(title_of "$BOARD/index.md")" "$(fm_value "$BOARD/index.md" id)"
for lane in "$BOARD"/*/; do
  [ -f "$lane/index.md" ] || continue
  o=$(fm_value "$lane/index.md" order)
  printf '%s\t%s\t%s\n' "${o:-999999999}" "$(title_of "$lane/index.md")" "$lane"
done | sort -n | while IFS=$'\t' read -r o t lane; do
  printf '\n== %s (order %s)\n' "$t" "$o"
  for card in "$lane"*/; do
    [ -f "$card/index.md" ] || continue
    co=$(fm_value "$card/index.md" order)
    printf '%s\t%s\t%s\n' "${co:-999999999}" "$(card_title_of "$card/index.md")" "$(basename "$card")"
  done | sort -n | while IFS=$'\t' read -r co ct cid; do
    printf '   %-8s %s  [%s]%s\n' "$co" "$ct" "${cid:0:8}" "$(pri_suffix "$cid")"
  done
done
