#!/bin/bash
# classify-event.sh: class a watcher burst from its paths and stamps, so the router never opens a card.
# usage: classify-event.sh [--state <dir>] <board> <line>...
#
# <line>: a Monitor line as watch-boards.sh prints it (`CHANGED <Board>.lanework/<path>`,
# `BULK: <n> files changed in <Board>.lanework`), or a bare path: absolute, or relative to
# the board or to its parent. Lines naming another board are ignored.
#
# Prints one tab-separated line per card and kind:
#   <kind> <board folder> <card uuid> <lane title> <card title> <author> <paths, comma-joined>
# kind:
#   comment   a comment file under the card that did not just travel with a move
#   move      the card's paths name a lane it is no longer in (lane title = where it is now,
#             `.trash`, or `-` when gone), or the card was just created: its index.md is in the
#             burst and `created.at` is under MOVE_FRESH seconds old (filed straight into a lane)
#   body      the card's own files changed, no move and no new comment
#   bulk      a BULK line: card, lane, title, author `-`; the paths field is the file count
#   self      every path is in the registry (`state.sh is-self`), or the stamp that changed
#             carries session "board dispatch"
#   excluded  the card's lane is recorded out of scope (`state.sh is-excluded`)
# author: owner (no `by`, or `kind: human`), agent (any other `by`), `-` (bulk).
# A move's author reads `modified.by`, and is the owner unless that stamp is under MOVE_FRESH
# seconds old (default 120): a bare mv leaves the previous writer's stamp in place, whoever
# wrote it, so a stale agent or dispatch stamp is the owner's move too. A created card's author
# reads `created.by`.
# Registered paths are dropped before classing, so an owner comment beside a self-write
# still prints as a comment. Board files outside any card print nothing.
# Needs yq (mikefarah v4).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="usage: classify-event.sh [--state <dir>] <board> <line>..."
STATE=
if [ "${1:-}" = --state ]; then STATE="${2:-}"; [ -n "$STATE" ] || { echo "$USAGE" >&2; exit 2; }; shift 2; fi
[ $# -ge 1 ] || { echo "$USAGE" >&2; exit 2; }
BOARD="${1%/}"; shift
[ -f "$BOARD/index.md" ] || { echo "classify-event.sh: not a board: $BOARD" >&2; exit 2; }
ARG="$BOARD"; BOARD="$(cd "$BOARD" && pwd)"; NAME="${BOARD##*/}"
command -v yq >/dev/null || { echo "classify-event.sh: needs yq (mikefarah v4)" >&2; exit 2; }
ST="$(dirname "${BASH_SOURCE[0]}")/state.sh"
SESSION="board dispatch"; FRESH="${MOVE_FRESH:-120}"

fm() { awk '/^---$/{n++; next} n==1' "$1"; }
# stamp <file> <created|modified>: "<who>\t<at>", who = owner | agent | self
stamp() {
  local t k s at
  # `|`-joined, not tab: read folds runs of tabs, so an empty field would shift the rest
  IFS='|' read -r t k s at < <(fm "$1" | yq -r ".$2 as \$s | [(\$s.by | type), ((\$s.by | select(type == \"!!map\") | .kind) // \"\"), ((\$s.by | select(type == \"!!map\") | .session) // \"\"), (((\$s | select(type == \"!!map\") | .at) // \$s) // \"\")] | join(\"|\")" 2>/dev/null || true) || true
  if [ "${s:-}" = "$SESSION" ]; then printf 'self\t%s' "${at:-}"
  elif [ -z "${t:-}" ] || [ "$t" = '!!null' ] || [ "${k:-}" = human ]; then printf 'owner\t%s' "${at:-}"
  else printf 'agent\t%s' "${at:-}"; fi
}
epoch() { date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s 2>/dev/null || echo 0; }
is_self() { [ -n "$STATE" ] && "$ST" "$STATE" is-self "$1"; }
is_excluded() { [ -n "$STATE" ] && [ -n "$1" ] && "$ST" "$STATE" is-excluded "$BOARD" "$1"; }
title_of() { local t; t=$(strip_quotes "$(fm_value "$1" title)"); printf '%s' "${t:--}"; }
emit() { printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$NAME" "$2" "$3" "$4" "$5" "$6"; }

# group the paths by card, in first-seen order
CARDS=(); PATHS_FILE=$(mktemp "${TMPDIR:-/tmp}/classify.XXXXXX"); trap 'rm -f "$PATHS_FILE"' EXIT
for line in "$@"; do
  case "$line" in
    "BULK: "*" files changed in $NAME") n=${line#BULK: }; emit bulk - - - - "${n%% *}"; continue ;;
    BULK:*|"SKILLS CHANGED") continue ;;
  esac
  p="${line#CHANGED }"
  case "$p" in "$ARG"/*) p="$BOARD/${p#"$ARG"/}" ;; esac
  case "$p" in
    "$BOARD"/*) r="${p#"$BOARD"/}" ;;
    /*) continue ;;
    "$NAME"/*) r="${p#"$NAME"/}" ;;
    *.lanework/*) continue ;;
    *) r="$p" ;;
  esac
  lane="${r%%/*}"; rest="${r#*/}"; [ "$rest" != "$r" ] || continue
  card="${rest%%/*}"; sub="${rest#*/}"; [ "$sub" != "$rest" ] || continue   # <lane>/index.md: a lane file
  case "$lane$card" in .*) continue ;; esac
  case "$card" in .*|index.md) continue ;; esac
  case " ${CARDS[*]-} " in *" $card "*) ;; *) CARDS+=("$card") ;; esac
  printf '%s\t%s\t%s\t%s\n' "$card" "$lane" "$sub" "$r" >> "$PATHS_FILE"
done

for card in ${CARDS[@]+"${CARDS[@]}"}; do
  now_dir=$(ls -d "$BOARD"/*/"$card" 2>/dev/null | head -1 || true)
  if [ -n "$now_dir" ]; then cur="$(basename "$(dirname "$now_dir")")"; lt=$(title_of "$BOARD/$cur/index.md"); ct=$(title_of "$now_dir/index.md")
  elif [ -d "$BOARD/.trash/$card" ]; then cur=.trash; lt=.trash; ct=$(title_of "$BOARD/.trash/$card/index.md")
  else cur=; lt=-; ct=-; fi
  all=(); live=()
  while IFS=$'\t' read -r _ lane sub r; do
    all+=("$r"); is_self "$BOARD/$r" || live+=("$lane"$'\t'"$sub"$'\t'"$r")
  done < <(awk -F'\t' -v c="$card" '$1 == c' "$PATHS_FILE")
  joined=$(IFS=,; printf '%s' "${all[*]}")
  if [ ${#live[@]} -eq 0 ]; then
    who=owner; [ -n "$now_dir" ] && who=$(stamp "$now_dir/index.md" modified | cut -f1); [ "$who" = self ] && who=agent
    emit self "$card" "$lt" "$ct" "$who" "$joined"; continue
  fi
  excl=; is_excluded "$cur" && excl=1
  out() { if [ "$2" = self ]; then emit self "$card" "$lt" "$ct" agent "$joined"; elif [ -n "$excl" ]; then emit excluded "$card" "$lt" "$ct" "$2" "$joined"; else emit "$1" "$card" "$lt" "$ct" "$2" "$joined"; fi; }
  moved=; elsewhere=()
  for e in "${live[@]}"; do IFS=$'\t' read -r lane sub _ <<<"$e"; [ "$lane" = "$cur" ] || { moved=1; elsewhere+=("$sub"); }; done
  if [ -n "$moved" ]; then
    who=owner
    if [ -n "$now_dir" ]; then
      IFS=$'\t' read -r w at < <(stamp "$now_dir/index.md" modified; echo)
      [ "$w" = owner ] || [ $(( $(date +%s) - $(epoch "${at:-}") )) -gt "$FRESH" ] || who=$w
    fi
    out move "$who"
  elif [ -n "$now_dir" ]; then
    for e in "${live[@]}"; do
      IFS=$'\t' read -r _ sub _ <<<"$e"; [ "$sub" = index.md ] || continue
      IFS=$'\t' read -r w at < <(stamp "$now_dir/index.md" created; echo)
      if [ $(( $(date +%s) - $(epoch "${at:-}") )) -le "$FRESH" ]; then moved=1; out move "$w"; fi
      break
    done
  fi
  # a new comment: under the card's lane now, existing, and not one that travelled with the move
  cw=
  for e in "${live[@]}"; do
    IFS=$'\t' read -r lane sub _ <<<"$e"
    [ "$lane" = "$cur" ] || continue
    case "$sub" in comments/*/index.md) ;; *) continue ;; esac
    case "${sub#comments/}" in */*/*|.*) continue ;; esac
    case " ${elsewhere[*]-} " in *" $sub "*) continue ;; esac
    [ -f "$BOARD/$cur/$card/$sub" ] || continue
    w=$(stamp "$BOARD/$cur/$card/$sub" created | cut -f1)
    # several in one burst: owner beats agent beats self
    case "$w" in owner) cw=owner ;; agent) [ "$cw" = owner ] || cw=agent ;; self) [ -n "$cw" ] || cw=self ;; esac
  done
  [ -z "$cw" ] || out comment "$cw"
  if [ -z "$moved" ] && [ -z "$cw" ] && [ -n "$now_dir" ]; then out body "$(stamp "$now_dir/index.md" modified | cut -f1)"; fi
done
