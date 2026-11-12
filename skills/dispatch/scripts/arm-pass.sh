#!/bin/bash
# arm-pass.sh: class every card at arming from its files, so the router never opens a card.
# usage: arm-pass.sh <board> [<agent lane title>...]
#
# Lanes: every lane but Done is swept (Done is never a work order and its claims are history).
# `agent` lanes = the lane titles given, else every `| <lane> | agent |` row of
# lanework/references/board-kinds.md (a board's own lane bodies still win: the handler reports
# `out-of-scope`, and the router excludes the lane).
#
# Prints one tab-separated line per card and kind, in reading order, the same seven fields
# classify-event.sh prints (<kind> <board folder> <card uuid> <lane title> <card title> <author> <paths>):
#   comment  the card's newest owner comment has no agent comment `in-reply-to` it. Author `owner`,
#            paths = that comment's path. Wins over arm on the same card.
#   arm      an unclaimed card in an agent lane (Approved: its top card only, by `order`). Author and paths `-`.
#   stale    a claim, and nothing newer on the card for STALE_MINUTES (default 30). Author `-`, paths =
#            the minutes of silence, `<n>m`. Report-only: the router never routes it, nothing is released.
# Claim = the card's last comment opening `START` (bold or plain) with no later closing comment. A closing
# comment opens `Merged`, `Closed`, `Shipped`, `Done`, `Confirmed done`, `Released`, `Landed` or `Abandoned`
# (bold or plain); a closing comment in any other shape reads as still claimed.
# Owner = no `by`, or `by.kind: human`, as classify-event.sh reads it. Every comment's `created.at` orders the thread.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="usage: arm-pass.sh <board> [<agent lane title>...]"
[ $# -ge 1 ] || { echo "$USAGE" >&2; exit 2; }
BOARD="${1%/}"; shift
[ -f "$BOARD/index.md" ] || { echo "arm-pass.sh: not a board: $BOARD" >&2; exit 2; }
BOARD="$(cd "$BOARD" && pwd)"; NAME="${BOARD##*/}"
STALE_MIN="${STALE_MINUTES:-30}"
AGENT_LANES=$'\n'
if [ $# -gt 0 ]; then for t in "$@"; do AGENT_LANES+="$t"$'\n'; done
else
  KINDS="$(dirname "${BASH_SOURCE[0]}")/../../lanework/references/board-kinds.md"
  [ -f "$KINDS" ] || { echo "arm-pass.sh: no $KINDS: pass the agent lane titles" >&2; exit 2; }
  AGENT_LANES+="$(awk -F'|' '$3 ~ /^ *agent *$/ { t=$2; gsub(/^ +| +$/, "", t); print t }' "$KINDS")"$'\n'
fi
epoch() { date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s 2>/dev/null || echo 0; }
title_of() { local t; t=$(strip_quotes "$(fm_value "$1" title)"); printf '%s' "${t:--}"; }

# row <comment index.md>: "<at>|<author>|<in-reply-to>|<first body line>"
row() {
  awk '
    function flush() { if (key == "created") { at = ""; if (match(blk, /at: *"?[0-9T:Z-]+/)) { at = substr(blk, RSTART, RLENGTH); sub(/at: *"?/, "", at) }
      who = (blk !~ /by:/ || blk ~ /kind: *"?human/) ? "owner" : "agent" } key = ""; blk = "" }
    BEGIN { n = 0 }
    /^---[ \t]*$/ { n++; if (n == 2) { flush(); infm = 0 } next }
    n == 1 { if ($0 ~ /^[A-Za-z-]+:/) { flush(); key = $0; sub(/:.*/, "", key); blk = $0
               if (key == "in-reply-to") { rep = $0; sub(/^in-reply-to: */, "", rep); gsub(/["\r]/, "", rep) } }
             else blk = blk " " $0
             next }
    n >= 2 && !got && $0 !~ /^[ \t\r]*$/ { first = $0; sub(/\r$/, "", first); got = 1 }
    END { printf "%s|%s|%s|%s\n", at, who, rep, first }
  ' "$1"
}

now=$(date +%s)
printf '%s\n' "$BOARD"/*/ | while IFS= read -r lane; do
  lane="${lane%/}"; [ -f "$lane/index.md" ] || continue
  case "$(basename "$lane")" in .*) continue ;; esac
  o=$(fm_value "$lane/index.md" order)
  printf '%s\t%s\n' "${o:-999999999}" "$lane"
done | sort -n | while IFS=$'\t' read -r _ lane; do
  lt=$(title_of "$lane/index.md")
  case "$lt" in [Dd]one) continue ;; esac
  agent=; case "$AGENT_LANES" in *$'\n'"$lt"$'\n'*) agent=1 ;; esac
  top=1
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
    own_uuid=; own_path=; start_at=; closed=; newest=
    declare -a replies=()
    while IFS='|' read -r uuid path at who rep first; do
      [ -n "$uuid" ] || continue
      newest="$at"
      [ "$who" = owner ] && { own_uuid=$uuid; own_path="${path#"$BOARD"/}/index.md"; }
      [ "$who" = agent ] && [ -n "$rep" ] && replies+=("$rep")
      b="${first#\*\*}"; b="${b#\*}"
      case "$b" in START*) start_at="$at"; closed= ;; esac
      if [ -n "$start_at" ]; then case "$b" in Merged*|Closed*|Shipped*|Done*|Confirmed\ done*|Released*|Landed*|Abandoned*) closed=1 ;; esac; fi
    done <<<"$rows"
    claimed=; [ -n "$start_at" ] && [ -z "$closed" ] && claimed=1
    answered=; for r in ${replies[@]+"${replies[@]}"}; do [ "$r" = "$own_uuid" ] && answered=1; done
    istop=$top; top=
    # the top card of Approved is the first in order, claimed or not; the next never takes its place
    if [ -n "$own_uuid" ] && [ -z "$answered" ]; then
      printf 'comment\t%s\t%s\t%s\t%s\towner\t%s\n' "$NAME" "$id" "$lt" "$ct" "$own_path"
    elif [ -n "$agent" ] && [ -z "$claimed" ] && { [ "$lt" != Approved ] || [ -n "$istop" ]; }; then
      printf 'arm\t%s\t%s\t%s\t%s\t-\t-\n' "$NAME" "$id" "$lt" "$ct"
    fi
    if [ -n "$claimed" ]; then
      quiet=$(( (now - $(epoch "$newest")) / 60 ))
      [ "$quiet" -lt "$STALE_MIN" ] || printf 'stale\t%s\t%s\t%s\t%s\t-\t%sm\n' "$NAME" "$id" "$lt" "$ct" "$quiet"
    fi
  done
done
