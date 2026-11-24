#!/bin/bash
# deps.sh: a ticket's dependencies, for frontier.sh and resolve-ticket.sh. Source it after lanework/scripts/lib.sh; never run it.
# usage: . "$(dirname "${BASH_SOURCE[0]}")/deps.sh"   Run directly: exit 2, nothing done.
# A dependency = one `depends-on` relation on the dependent ticket (guide § Relations), read by lib.sh `relation_targets`: rel in any case, `_` or
# space for `-`, quoted values, relations/.trash skipped. The ticket body is never read for dependencies.
#
# card_of <board> <uuid | link>: the card's folder. A bare uuid matches exactly. A link `lanework://<board>/<card>`, full or short: the board segment
#   must be this board's id or a prefix of it (8+ hex digits), the card segment a full id or a unique prefix (8+). Return 0 found (path printed),
#   1 no such card (or the link names no card), 2 a short link matching several cards, 3 another board's link. Nothing printed unless 0.
# lane_of <board> <uuid>: the title of the lane holding that card; empty when none.
# deps_of <board> <card dir>: one line per dependency: the target card's uuid, else `missing:<to>`, `elsewhere:<to>` or `ambiguous:<to>`.
#   Order: the tickets found, by ticket number (T<n>), then the rest; ties by the `to` as written, bytewise. Never the relation folders' order
#   (random uuids), so every reader prints a ticket's dependencies the same way on every run.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then echo "deps.sh: source it, never run it" >&2; exit 2; fi

card_of() {
  local b="$1" r="$2" bid bseg cseg d n=0 hit=""
  if [[ "$r" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    d=$(ls -d "$b"/*/"$r" 2>/dev/null | head -1 || true)
    [ -n "$d" ] && [ -f "$d/index.md" ] || return 1
    printf '%s' "$d"; return 0
  fi
  r=$(printf '%s' "$r" | tr 'A-F' 'a-f')
  [[ "$r" =~ ^lanework://([0-9a-f-]{8,})/([0-9a-f-]{8,})$ ]] || return 1
  bseg=${BASH_REMATCH[1]}; cseg=${BASH_REMATCH[2]}
  bid=$(fm_value "$b/index.md" id)
  case "$bid" in "$bseg"*) ;; *) return 3 ;; esac
  for d in "$b"/*/"$cseg"*; do
    [ -f "$d/index.md" ] || continue
    if [ "$(basename "$d")" = "$cseg" ]; then hit="$d"; n=1; break; fi
    n=$((n + 1)); hit="$d"
  done
  [ "$n" -gt 0 ] || return 1
  [ "$n" -eq 1 ] || return 2
  printf '%s' "$hit"
}

lane_of() { local d; d=$(card_of "$1" "$2" || true); [ -n "$d" ] && strip_quotes "$(fm_value "$(dirname "$d")/index.md" title)"; }

deps_of() {
  local to c rc
  while IFS= read -r to; do
    rc=0; c=$(card_of "$1" "$to") || rc=$?
    case $rc in
      0) printf '0\t%s\t%s\t%s\n' "$(ticket_no "$c/index.md")" "$to" "$(basename "$c")" ;;
      2) printf '1\t0\t%s\tambiguous:%s\n' "$to" "$to" ;;
      3) printf '1\t0\t%s\telsewhere:%s\n' "$to" "$to" ;;
      *) printf '1\t0\t%s\tmissing:%s\n' "$to" "$to" ;;
    esac
  done < <(relation_targets "$2" depends-on) | LC_ALL=C sort -t "$(printf '\t')" -k1,1n -k2,2n -k3,3 | cut -f4-
}

# ticket_no <index.md>: the ticket's number for deps_of's order: its `cite-as` T<n>, else a `T<n>: ` title prefix; else 999999999 (after
# every numbered ticket)
ticket_no() {
  local t; t=$(cite_of "$1"); [ -n "$t" ] || t=$(strip_quotes "$(fm_value "$1" title)")
  if [[ "$t" =~ ^T0*([0-9]{1,9})(:|$) ]]; then printf '%s' "${BASH_REMATCH[1]}"; else printf '999999999'; fi
}
