#!/bin/bash
# read-board.sh: print a board in reading order: lanes by `order`, cards by `order` within each.
# usage: read-board.sh "<path>/<Name>.lanework"
# Missing `order` sorts last. Dot-folders (.schema, .log, .trash) are skipped.
# Titles and ids only; read the bodies next (references/reading.md).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
BOARD="${1:?usage: read-board.sh <board>}"
[ -f "$BOARD/index.md" ] || { echo "read-board.sh: not a board: $BOARD" >&2; exit 1; }

title_of() { strip_quotes "$(fm_value "$1" title)"; }
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
    printf '%s\t%s\t%s\n' "${co:-999999999}" "$(title_of "$card/index.md")" "$(basename "$card")"
  done | sort -n | while IFS=$'\t' read -r co ct cid; do
    printf '   %-8s %s  [%s]\n' "$co" "$ct" "${cid:0:8}"
  done
done
