#!/bin/bash
# Lint a board's stamps for the future.   Usage: lint-stamps.sh <board dir | index.md> [--slack <seconds>]
# Reads each index.md frontmatter (board, lanes, cards, comments) and compares every `created.at`,
# `modified.at` and `waiting.since` to the clock. A stamp more than <slack> seconds ahead (default 60,
# so the ask's deliberate one-second offset stays legal) is one line on stdout and exit 1:
#   <path>: <field> <value> is <n>s ahead
# Silent exit 0 when clean; exit 2 (message on stderr) on a missing path, a bad flag or no argument. Only
# `...Z` stamps are compared, quoted or not, flow or block form, CRLF files included; an offset stamp is
# skipped. Skips .trash, .log, .schema and attachments. Fix = restamp from the clock.
set -u
. "$(dirname "$0")/../../lanework/scripts/lib.sh"
USAGE="usage: lint-stamps.sh <board dir | index.md> [--slack <seconds>]"
[ $# -ge 1 ] || { echo "$USAGE" >&2; exit 2; }
target=$1; shift
slack=60
while [ $# -gt 0 ]; do
  case "$1" in
    --slack) [ $# -ge 2 ] || { echo "lint-stamps.sh: --slack needs a value" >&2; exit 2; }; slack=$2; shift 2 ;;
    *) echo "lint-stamps.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$slack" in ''|*[!0-9]*) echo "lint-stamps.sh: --slack needs whole seconds" >&2; exit 2 ;; esac
[ -e "$target" ] || { echo "no such path: $target" >&2; exit 2; }
limit=$(now_utc "$slack"); nowe=$(date -u +%s); v=0
if [ -d "$target" ]; then
  files() { find "$target" -mindepth 1 \( -name '.*' -o -name attachments \) -prune -o -type f -name index.md -print; }
else
  files() { printf '%s\n' "$target"; }
fi
epoch() { date -j -u -f %Y-%m-%dT%H:%M:%SZ "$1" +%s 2>/dev/null; }
while IFS=$'\t' read -r f field val; do
  [ -n "$f" ] || continue
  e=$(epoch "$val") || e=$nowe
  echo "$f: $field $val is $((e - nowe))s ahead"; v=1
done < <(files | while IFS= read -r f; do
  awk -v f="$f" -v limit="$limit" '
    # top(line, name): the text after `name:` when it is a key of the outermost flow mapping (after the
    # opening brace or a comma at depth 1, outside quotes), else "". Quoted contents are never a key.
    function top(l, name,   i, c, d, qt, ks, n, k) {
      d = 0; qt = ""; ks = 0; n = length(l); k = length(name) + 1
      for (i = 1; i <= n; i++) {
        c = substr(l, i, 1)
        if (qt != "") { if (c == "\\") i++; else if (c == qt) qt = ""; continue }
        if (c == "\"" || c == "\x27") { qt = c; ks = 0; continue }
        if (c == "{" || c == "[") { d++; ks = (d == 1 && c == "{"); continue }
        if (c == "}" || c == "]") { d--; continue }
        if (d == 1 && c == ",") { ks = 1; continue }
        if (d == 1 && ks && c != " " && c != "\t") { if (substr(l, i, k) == name ":") return substr(l, i + k); ks = 0 }
      }
      return ""
    }
    { sub(/\r$/, "") }
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    /^[A-Za-z-]+:/ { key = $0; sub(/:.*/, "", key) }
    { st = "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z"; fld = ""; v = ""; name = (key == "waiting") ? "since" : "at" }
    key == "created" || key == "modified" || key == "waiting" {
      if ($0 ~ ("^" key ":[ \t]*\\{")) v = top($0, name)
      else if ($0 ~ ("^[ \t]+" name ":")) { v = $0; sub(/^[ \t]+[a-z]+:/, "", v) }
      if (v != "") {
        sub(/^[ \t]*["\x27]?/, "", v)
        if (match(v, "^" st)) { t = substr(v, 1, RLENGTH); if (t > limit) printf "%s\t%s\t%s\n", f, (key == "waiting" ? "waiting.since" : key ".at"), t }
      }
    }' "$f"
done)
exit $v
