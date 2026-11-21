#!/bin/bash
# Lint a board for asks whose `waiting` an agent cleared (the owner's trial, work/references/writing.md § The ask).
# Usage: lint-waiting-clears.sh <board dir> [--since <ts>]
# Read-only. For each card: its newest ask is the newest comment by an agent whose body starts with `@` (any handle,
# the anyone handle or a person's). The card is listed when that ask has no later human comment, no human comment
# `in-reply-to` it, and the card has no `waiting` (flow or block form). One line per card on stdout:
#   QUOTED <card> <ask uuid>      an agent comment `in-reply-to` the ask has a `>` line and a `**Given**` line
#   NO-QUOTE <card> <ask uuid>    none does (also an ask that never got a mark: the two look alike)
# `--since <ts>` (UTC, 2026-11-14T15:30:00Z, as lint-leases.sh) lists only cards cleared at or after it: a card's clear time is the
# newest created.at among its ask and the agent comments in-reply-to it (an ask with no record: its own time). The tally counts the
# listed cards only. A stamp with fractional seconds is read to the whole second; an offset stamp is read as unreadable (UTC `Z` is the rule).
# then `QUOTED <n>, NO-QUOTE <m>`. Silent exit 0 when nothing is listed; exit 1 when any NO-QUOTE; exit 2
# (message on stderr) on a missing path, a file, a bad flag, no argument or a path it could not read
# (`lint-waiting-clears.sh: could not read <path>` on stderr, before the listed cards; what was read still lists). Skips .trash, .log, .schema and attachments.
# An ask here is looser than lint-ask.sh's: that one needs the board's human handle (guide line, or the anyone handle)
# on line 1 and checks the shape; this one takes any `@` that starts the first non-blank line and checks nothing else.
# Agent = a `created.by` with `kind: agent`; human = no `by`, or `kind: human`; any other kind (a shortcut) is neither an ask nor an answer.
# A quote is a `>` line with text after it, a Given line starts `**Given**:`; both count outside a code fence only.
set -u
. "$(dirname "$0")/../../lanework/scripts/lib.sh"
USAGE="usage: lint-waiting-clears.sh <board dir> [--since <ts>]"
[ $# -ge 1 ] || { echo "$USAGE" >&2; exit 2; }
board=$1; shift
since=""
while [ $# -gt 0 ]; do
  case "$1" in
    --since)
      [ -z "$since" ] || { echo "lint-waiting-clears.sh: --since given twice" >&2; exit 2; }
      [ $# -ge 2 ] || { echo "lint-waiting-clears.sh: --since needs a UTC time like 2026-11-14T15:30:00Z" >&2; exit 2; }
      since=$2; shift 2
      case "$since" in [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z) ;; *) echo "lint-waiting-clears.sh: --since needs a UTC time like 2026-11-14T15:30:00Z" >&2; exit 2 ;; esac ;;
    *) echo "lint-waiting-clears.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
[ -e "$board" ] || { echo "no such path: $board" >&2; exit 2; }
d=$board; case "$d" in -*) d=./$d ;; esac   # a leading - is no option for test
[ -d "$d" ] || { echo "lint-waiting-clears.sh: not a board folder: $board" >&2; exit 2; }
# comment_row <comment index.md>: created.at, agent|human|other, in-reply-to, ask (1/0), quoting (1/0), uuid; tab-separated
comment_row() {
  local id="${1%/index.md}"; id="${id##*/}"
  LW_ID="$id" awk "$SHOW_NAME_AWK"'   # the id rides in the environment: awk -v rejects a newline in it
    BEGIN { id = ENVIRON["LW_ID"] }
    { sub(/\r$/, "") }
    NR == 1 { if ($0 == "---") fm = 1; next }
    fm && $0 == "---" { fm = 0; body = 1; next }
    fm && /^[A-Za-z-]+:/ { key = $0; sub(/:.*/, "", key); if (key == "created") cr = cr " " $0; if (key == "in-reply-to") { irt = $0; sub(/^[^:]*:[ \t]*["\x27]?/, "", irt); sub(/["\x27 \t]*$/, "", irt) } next }
    fm && key == "created" && /^[ \t]/ { cr = cr " " $0; next }
    body && !seen && $0 !~ /^[ \t]*$/ { seen = 1; ask = ($0 ~ /^@/) }
    body && /^[ \t]*(```|~~~)/ { fence = !fence; next }
    body && !fence && /^>[ \t]*[^ \t]/ { q = 1 }
    body && !fence && /^\*\*Given\*\*:/ { g = 1 }
    END {
      id = show_name(id)   # escaped (lib.sh show_name): a tab or newline would split the row
      at = ""
      if (match(cr, /(^|[ {,])at:[ \t]*["\x27]?[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z/)) { s = substr(cr, RSTART, RLENGTH); match(s, /[0-9]{4}-.*$/); at = substr(s, RSTART); sub(/\.[0-9]+Z$/, "Z", at) }
      kind = "human"
      if (cr ~ /(^|[ {,])by:/ && match(cr, /kind:[ \t]*["\x27]?[A-Za-z]+/)) { kind = substr(cr, RSTART, RLENGTH); sub(/^kind:[ \t]*["\x27]?/, "", kind); if (kind != "agent" && kind != "human") kind = "other" }
      printf "%s\t%s\t%s\t%d\t%d\t%s\n", at, kind, irt, ask + 0, (q && g) + 0, id
    }' "$(dp "$1")"
}
# has_waiting <card index.md>: a top-level `waiting:` key in the frontmatter, flow or block
dp() { case "$1" in -*) printf './%s' "$1" ;; *) printf '%s' "$1" ;; esac; }   # a path that starts with - is no awk option
has_waiting() { awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { exit } fm && /^waiting:/ { f = 1 } END { exit !f }' "$(dp "$1")"; }
quoted=0; noquote=0; unread=0
LIST=$(mktemp "${TMPDIR:-/tmp}/lw-wc.XXXXXX") || exit 2; trap 'rm -f "$LIST"' EXIT
board_index_files "$board" "$LIST" || unread=1
while IFS= read -r -d '' idx; do   # a card is <board>/<lane>/<card>/index.md; the helper skips .trash, .log, .schema
  [ -n "$idx" ] || continue
  rel=${idx#"$board"}; rel=${rel#/}; rel=${rel#/}; rel=${rel%/index.md}
  case "$rel" in */*/*) continue ;; */*) ;; *) continue ;; esac
  card=${idx%/index.md};   # no $(dirname): it would strip a trailing newline from the name
  has_waiting "$idx" && continue
  rows=""
  for c in "$card"/comments/*/index.md; do
    [ -f "$c" ] && [ -r "$c" ] || continue   # an unreadable one: the helper already printed its could-not-read line
    rows="$rows$(comment_row "$c")"$'\n'
  done
  [ -n "$rows" ] || continue
  res=$(printf '%s' "$rows" | awk -F'\t' '
    $1 != "" { n++; c[n] = $1; k[n] = $2; r[n] = $3; a[n] = $4; q[n] = $5; u[n] = $6 }
    END {
      for (i = 1; i <= n; i++) if (k[i] == "agent" && a[i] == 1 && (!b || c[i] > c[b] || (c[i] == c[b] && u[i] > u[b]))) b = i
      if (!b) exit
      for (i = 1; i <= n; i++) if (k[i] == "human" && (c[i] > c[b] || r[i] == u[b])) exit
      s = "NO-QUOTE"; for (i = 1; i <= n; i++) if (k[i] == "agent" && r[i] == u[b] && q[i] == 1) s = "QUOTED"
      t = c[b]; for (i = 1; i <= n; i++) if (k[i] == "agent" && r[i] == u[b] && c[i] > t) t = c[i]
      print s "\t" u[b] "\t" t
    }')
  [ -n "$res" ] || continue
  IFS=$'\t' read -r verdict ask clear <<<"$res"   # tab-separated: an id may hold a space
  [ -z "$since" ] || [ ! "$clear" \< "$since" ] || continue
  printf '%s %s %s\n' "$verdict" "$(show_name "${card##*/}")" "$ask"
  case "$res" in QUOTED*) quoted=$((quoted + 1)) ;; *) noquote=$((noquote + 1)) ;; esac
done < <(sort -z "$LIST")
[ $((quoted + noquote)) -eq 0 ] || echo "QUOTED $quoted, NO-QUOTE $noquote"
[ "$unread" -eq 0 ] || exit 2
[ "$noquote" -eq 0 ]
