#!/bin/bash
# check-sizes.sh: the README's § Sizes word counts must equal `wc -w` of the files under skills/.
# usage: tests/check-sizes.sh [<repo root>]   (default: this repo; a scratch copy works too)
# Rules: every row of a skill's table = wc -w of that file; `total` = sum of the rows;
# the summary table's files / SKILL.md words / words an agent reads = the skill table's
# row count / SKILL.md row / total. SKILL.md and every references/*.md must have a row.
# Templates are checked only when listed.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1
bad=0; rows=0
fail() { echo "$1"; bad=$((bad+1)); }

# S <skill> <files> <skillmd> <total> | R <skill> <path> <n> | T <skill> <n>
# per-skill tables sit under `#### skill` headings
parsed=$(awk '
  /^### Sizes/ { on=1; next }
  on && /^## / { on=0 }
  !on { next }
  /^#### / { s=$2; gsub(/`/, "", s); sk=s; next }
  !/^\|/ { next }
  { n=split($0, c, "|"); for (i=1;i<=n;i++) gsub(/[`*, ]/, "", c[i]) }
  c[2]=="skill" || c[2]=="file" || c[2] ~ /^-+$/ { next }
  n==6 { print "S", c[2], c[3], c[4], c[5]; next }
  n==4 && c[2]=="total" { print "T", sk, c[3]; next }
  n==4 { print "R", sk, c[2], c[3] }
  ' README.md)
[ -n "$parsed" ] || { echo "check-sizes: no § Sizes tables found in README.md"; exit 1; }

for d in skills/*/; do
  s=$(basename "$d")
  # every SKILL.md and references/*.md needs a row
  for p in "$d"SKILL.md "$d"references/*.md; do
    [ -e "$p" ] || continue
    f=${p#"$d"}
    grep -q "^R $s $f " <<<"$parsed" || fail "$s/$f: no README row (wc -w says $(wc -w < "$d$f" | tr -d ' '))"
  done
  grep -q "^S $s " <<<"$parsed" || fail "$s: no row in the README summary table"
  sum=0; cnt=0; skillmd=""
  while read -r _ _ f n; do
    rows=$((rows+1)); cnt=$((cnt+1))
    if [ ! -e "$d$f" ]; then fail "$s/$f: README says $n, file does not exist"; continue; fi
    m=$(wc -w < "$d$f" | tr -d ' ')
    [ "$n" = "$m" ] || fail "$s/$f: README says $n, wc -w says $m"
    sum=$((sum+n)); [ "$f" = SKILL.md ] && skillmd=$n
  done < <(grep "^R $s " <<<"$parsed")
  t=$(grep "^T $s " <<<"$parsed" | cut -d' ' -f3)
  [ -z "$t" ] && fail "$s/total: no total row in the README table"
  [ -z "$t" ] || [ "$t" = "$sum" ] || fail "$s/total: README says $t, sum of rows says $sum"
  sl=$(grep "^S $s " <<<"$parsed")
  if [ -n "$sl" ]; then
    set -- $sl
    [ "$3" = "$cnt" ] || fail "$s/summary files: README says $3, table has $cnt rows"
    [ "$4" = "${skillmd:-0}" ] || fail "$s/summary SKILL.md words: README says $4, SKILL.md row says ${skillmd:-none}"
    [ "$5" = "${t:-0}" ] || fail "$s/summary words an agent reads: README says $5, total row says ${t:-none}"
  fi
done
echo "check-sizes: $rows rows, $bad wrong"
[ "$rows" -gt 0 ] && [ "$bad" -eq 0 ]
