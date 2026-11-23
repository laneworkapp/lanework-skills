#!/bin/bash
# frontier.sh: print a plan board's live tickets; warn on drift. Read-only.
# usage: frontier.sh <board>
# A ticket with a `cite-as` prints as `<citation>: <title>`, and messages name the citation; one without prints and is named by its title.
# Prints Frontier tickets in order (the top is next), then Blocked tickets each with the
# dependencies not yet Resolved, then Working tickets (`waiting` marked). A dependency = a `depends-on` relation (deps.sh). Warns on stderr when
# a lane disagrees with its tickets' dependencies: a Blocked ticket with every dependency Resolved or none (with a hint when its body still
# carries an old dependency list, which is not read), a Frontier ticket with one open, a dependency pointing at a missing card, another board's
# card, a short link matching several cards, or an Out of scope card. Exit 0 on a board, warnings or not. Exit 2: no argument or an unknown argument (a first argument starting with `-` is one). Exit 1: not a board.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
. "$(dirname "${BASH_SOURCE[0]}")/deps.sh"

[ $# -eq 1 ] || { echo "usage: frontier.sh <board>" >&2; exit 2; }
case "$1" in -*) echo "frontier.sh: unknown argument: $1" >&2; echo "usage: frontier.sh <board>" >&2; exit 2 ;; esac
BOARD="$1"
[ -f "$BOARD/index.md" ] || { echo "frontier.sh: not a board: $BOARD" >&2; exit 1; }
BOARD_ID=$(fm_value "$BOARD/index.md" id)

# waiting_set <index.md>: a `waiting` with a value, inline or opened out into block lines by the compact form
waiting_set() {
  awk 'NR==1 && $0=="---" { fm=1; next } fm && $0=="---" { exit }
    fm && w && /^[ \t]/ { f=1; exit }
    fm { w=0 }
    fm && /^waiting:/ { v=$0; sub(/^waiting:[ \t]*/, "", v); if (v != "") { f=1; exit } w=1 }
    END { exit !f }' "$1"
}
title_of() { strip_quotes "$(fm_value "$1/index.md" title)" | perl -pe 's/\\(.)/$1/g'; }
name_of() { local c; c=$(cite_of "$1/index.md"); if [ -n "$c" ]; then printf '%s' "$c"; else title_of "$1"; fi; }   # how a message names a ticket
label_of() { local c; c=$(cite_of "$1/index.md"); if [ -n "$c" ]; then printf '%s: %s' "$c" "$(title_of "$1")"; else title_of "$1"; fi; }   # the listing line
cards_in() {  # cards_in <lane title>: card dirs in order
  local lane g; lane=$(lane_by_title "$BOARD" "$1") || return 0
  for g in "$lane"/*/index.md; do [ -f "$g" ] && printf '%s\t%s\n' "$(fm_value "$g" order)" "$(dirname "$g")"; done | sort -n | cut -f2-
}
warn() { echo "frontier.sh: drift: $*" >&2; }

for LANE in Frontier Blocked Working; do
  echo "== $LANE"
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    id=$(basename "$c"); t=$(name_of "$c")
    w=""; waiting_set "$c/index.md" && w="  (waiting)"
    printf '%s  [%s](lanework://%s/%s)%s\n' "$(label_of "$c")" "${id:0:8}" "$BOARD_ID" "$id" "$w"
    open=(); n=0
    while IFS= read -r d; do
      n=$((n+1))
      case "$d" in
        missing:*)   warn "$t depends on a missing card ${d#*:}"; open+=("missing ${d#*:}"); continue ;;
        elsewhere:*) warn "$t depends on ${d#*:}, another board's card: plan reads dependencies on this board only"; open+=("elsewhere ${d#*:}"); continue ;;
        ambiguous:*) warn "$t depends on ${d#*:}, a short link matching several cards: write the full link"; open+=("ambiguous ${d#*:}"); continue ;;
      esac
      l=$(lane_of "$BOARD" "$d" || true)
      [ "$l" = "Out of scope" ] && warn "$t depends on $(name_of "$(card_of "$BOARD" "$d")"), which is Out of scope: rule it out too, or drop the dependency"
      [ "$l" = Resolved ] || open+=("$(name_of "$(card_of "$BOARD" "$d")") ($l)")
    done < <(deps_of "$BOARD" "$c")
    if [ "$LANE" = Blocked ]; then
      for o in ${open[@]+"${open[@]}"}; do printf '    waits on %s\n' "$o"; done
      hint=""; [ "$n" -gt 0 ] || ! grep -q '^## Depends on[ \t]*$' "$c/index.md" || hint="; its ## Depends on list is not read: re-enter those as depends-on relations (guide § Relations)"
      [ "${#open[@]}" -gt 0 ] || warn "$t is Blocked but $([ "$n" -gt 0 ] && echo 'every dependency is Resolved' || echo 'names no dependency'): move it to Frontier$hint"
    fi
    if [ "$LANE" = Frontier ] && [ "${#open[@]}" -gt 0 ]; then warn "$t is on the Frontier with a dependency open: ${open[*]}"; fi
  done < <(cards_in "$LANE")
done
exit 0
