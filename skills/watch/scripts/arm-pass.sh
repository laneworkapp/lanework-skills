#!/bin/bash
# arm-pass.sh: class every card at arming from its files, so the watch learns which cards to open.
# usage: arm-pass.sh <board> [<agent lane title>...]
#
# Lanes: every lane but Done is swept (Done is never a work order and its leases are history).
# `agent` lanes = the lane titles given, else every `| <lane> | agent |` row of
# lanework/references/board-kinds.md (a board's own lane bodies still win: a lane whose body says it's
# out of scope is skipped by the watch).
#
# Prints one tab-separated line per card and kind, in reading order, seven fields
# (<kind> <board folder> <card uuid> <lane title> <card title> <author> <paths>):
#   comment  the card's newest owner comment has no agent comment `in-reply-to` it. Author `owner`,
#            paths = that comment's path. Wins over arm on the same card.
#   arm      a card in an agent lane with no lease (none, or voided by the clock guard; Approved: its first card only, by priority rank then `order`: lanework/references/reading.md § Pick order). Author and paths `-`.
#            A START comment is no claim: only a lease is.
#   held     a valid lease: any lane but Done. Author `-`, paths = the minutes left, `<n>m`. Report-only.
#   stale    a lapsed lease (past `until`): any lane but Done. Author `-`, paths = the minutes since `until`, `<n>m`.
#            Report-only: never worked, never taken over, never released.
# Leases are read once, through the read-only `lease.sh list <board>`, and joined to cards by uuid. Its state column decides:
# live = held, lapsed = stale, voided (the clock guard) or no row = no lease. No lease rule is restated here, and nothing is
# written. `lease.sh list` needs no session id. If it fails or is missing, no lease is known, so nothing is armed or reported
# as held: `comment` lines still print (they read no lease), the failure goes to stderr and the exit is 1. An `arm` printed
# without leases could double-dispatch a card another session holds.
# A comment signed `board` (the app's move receipt, a `moved:` key) counts for nothing: not a reply.
# Exit 0 = swept. Exit 1 = `lease.sh list` failed or is missing (above). Exit 2 = usage or setup, nothing printed:
# no argument, not a board, no board-kinds.md (when no lane titles are given).
# Owner = no `by`, or `by.kind: human` (either quote). CRLF files are read. Every comment's `created.at` orders the thread.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="usage: arm-pass.sh <board> [<agent lane title>...]"
[ $# -ge 1 ] || { echo "$USAGE" >&2; exit 2; }
BOARD="${1%/}"; shift
[ -f "$BOARD/index.md" ] || { echo "arm-pass.sh: not a board: $BOARD" >&2; exit 2; }
BOARD="$(cd "$BOARD" && pwd)"; NAME="${BOARD##*/}"
PRI=$(priorities_of "$BOARD"/*/*/index.md 2>/dev/null || true)   # one Python start per board: `<card path>\t<text>\t<rank>`
LEASE="$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lease.sh"
LEASES=; LEASE_OK=1
if [ -f "$LEASE" ] && LEASES=$(bash "$LEASE" list "$BOARD"); then :
else LEASES=; LEASE_OK=; echo "arm-pass.sh: lease.sh list failed or is missing: no arm, held or stale lines; comment lines only" >&2; fi
AGENT_LANES=$'\n'
if [ $# -gt 0 ]; then for t in "$@"; do AGENT_LANES+="$t"$'\n'; done
else
  KINDS="$(dirname "${BASH_SOURCE[0]}")/../../lanework/references/board-kinds.md"
  [ -f "$KINDS" ] || { echo "arm-pass.sh: no $KINDS: pass the agent lane titles" >&2; exit 2; }
  AGENT_LANES+="$(awk -F'|' '$3 ~ /^ *agent *$/ { t=$2; gsub(/^ +| +$/, "", t); print t }' "$KINDS")"$'\n'
fi
title_of() { local t; t=$(strip_quotes "$(fm_value "$1" title)"); printf '%s' "${t:--}"; }

# row <comment index.md>: "<at>|<author>|<in-reply-to>|<first body line>"
row() {
  awk '
    function flush() { if (key == "created") { at = ""; if (match(blk, /at: *["\x27]?[^,}"\x27 ]+/)) { at = substr(blk, RSTART, RLENGTH); sub(/at: *["\x27]?/, "", at); sub(/\.[0-9]+Z$/, "Z", at) }
      who = (blk !~ /by:/ || blk ~ /kind: *["\x27]?human/) ? "owner" : (blk ~ /name: *["\x27]?board["\x27]?[ ,}]/ ? "board" : "agent") } key = ""; blk = "" }
    BEGIN { n = 0 }
    { sub(/\r$/, "") }
    /^---[ \t]*$/ { n++; if (n == 2) { flush(); infm = 0 } next }
    n == 1 { if ($0 ~ /^[A-Za-z-]+:/) { flush(); key = $0; sub(/:.*/, "", key); blk = $0
               if (key == "in-reply-to") { rep = $0; sub(/^in-reply-to: */, "", rep); gsub(/["\r]/, "", rep) } }
             else blk = blk " " $0
             next }
    n >= 2 && !got && $0 !~ /^[ \t\r]*$/ { first = $0; sub(/\r$/, "", first); got = 1 }
    END { printf "%s|%s|%s|%s\n", at, who, rep, first }
  ' "$1"
}

printf '%s\n' "$BOARD"/*/ | while IFS= read -r lane; do
  lane="${lane%/}"; [ -f "$lane/index.md" ] || continue
  case "$(basename "$lane")" in .*) continue ;; esac
  o=$(fm_value "$lane/index.md" order)
  printf '%s\t%s\n' "${o:-999999999}" "$lane"
done | sort -n | while IFS=$'\t' read -r _ lane; do
  lt=$(title_of "$lane/index.md")
  case "$lt" in [Dd]one) continue ;; esac
  agent=; case "$AGENT_LANES" in *$'\n'"$lt"$'\n'*) agent=1 ;; esac
  topcard=
  if [ "$lt" = Approved ]; then   # the first card by (rank, order); no rank sorts last
    topcard=$(for card in "$lane"/*/; do
      card="${card%/}"; [ -f "$card/index.md" ] || continue
      co=$(fm_value "$card/index.md" order)
      rk=-; [ -z "$PRI" ] || rk=$(printf '%s\n' "$PRI" | awk -F'\t' -v p="$card/index.md" '$1 == p && $3 != "-" { print $3; found = 1; exit } END { if (!found) print "-" }')
      printf '%s\t%s\t%s\n' "$rk" "${co:-999999999}" "$card"
    done | awk -F'\t' '{ r = ($1 == "-") ? 1 : 0; k = $1 + 0; o = $2 + 0   # ranked before unranked, compared explicitly: no sentinel a big rank could pass
      if (!n || r < br || (r == br && (k < bk || (k == bk && (o < bo || (o == bo && $3 < bc)))))) { n = 1; br = r; bk = k; bo = o; bc = $3 } }
      END { print bc }')
  fi
  for card in "$lane"/*/; do
    card="${card%/}"; [ -f "$card/index.md" ] || continue
    co=$(fm_value "$card/index.md" order)
    printf '%s\t%s\n' "${co:-999999999}" "$card"
  done | sort -n | while IFS=$'\t' read -r _ card; do
    id=$(basename "$card"); ct=$(title_of "$card/index.md")
    rows=$(for c in "$card"/comments/*/; do
      c="${c%/}"; [ -f "$c/index.md" ] || continue
      cn="${c##*/}"; [ "${cn#.}" = "$cn" ] || continue   # a dot-folder (.draft)
      printf '%s|%s|%s\n' "$(basename "$c")" "$c" "$(row "$c/index.md")"
    done | awk -F'|' '{ print $3 "|" $0 }' | sort | cut -d'|' -f2-)
    own_uuid=; own_path=
    declare -a replies=()
    while IFS='|' read -r uuid path _ who rep _; do
      [ -n "$uuid" ] || continue
      [ "$who" = board ] && continue   # the app'"'"'s move receipt: no reply
      [ "$who" = owner ] && { own_uuid=$uuid; own_path="${path#"$BOARD"/}/index.md"; }
      [ "$who" = agent ] && [ -n "$rep" ] && replies+=("$rep")
    done <<<"$rows"
    lstate=; lmins=
    if [ -n "$LEASE_OK" ]; then
      lrow=$(printf '%s\n' "$LEASES" | awk -F'\t' -v u="$id" '$1 == u { print $4 "\t" $3; exit }')
      lstate="${lrow%%$'\t'*}"; lmins="${lrow#*$'\t'}"; lmins="${lmins%% *}"
      case "$lstate" in live|lapsed) ;; *) lstate= ;; esac   # voided and no row: no lease
    fi
    answered=; for r in ${replies[@]+"${replies[@]}"}; do [ "$r" = "$own_uuid" ] && answered=1; done
    istop=; [ "$card" != "$topcard" ] || istop=1
    # the top card of Approved is the first by (rank, order), leased or not; the next never takes its place
    if [ -n "$own_uuid" ] && [ -z "$answered" ]; then
      printf 'comment\t%s\t%s\t%s\t%s\towner\t%s\n' "$NAME" "$id" "$lt" "$ct" "$own_path"
    elif [ -n "$LEASE_OK" ] && [ -n "$agent" ] && [ -z "$lstate" ] && { [ "$lt" != Approved ] || [ -n "$istop" ]; }; then
      printf 'arm\t%s\t%s\t%s\t%s\t-\t-\n' "$NAME" "$id" "$lt" "$ct"
    fi
    case "$lstate" in
      live) printf 'held\t%s\t%s\t%s\t%s\t-\t%sm\n' "$NAME" "$id" "$lt" "$ct" "$lmins" ;;
      lapsed) printf 'stale\t%s\t%s\t%s\t%s\t-\t%sm\n' "$NAME" "$id" "$lt" "$ct" "$lmins" ;;
    esac
  done
done
[ -n "$LEASE_OK" ] || exit 1
