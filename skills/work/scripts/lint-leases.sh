#!/bin/bash
# Lint a board's threads and cards for lease collisions, and for a started card that carries no lease.
# Usage: lint-leases.sh <board dir>... [--since <ts>] [--first <n>] [--window <s>] [--grace <s>]
# Read-only. One line per finding on stdout (sorted), exit 1 if any; silent exit 0 when clean; exit 2 (message on
# stderr) on a missing path, a dir that is no board, a bad flag value, no board or a path it could not read
# (`lint-leases.sh: could not read <path>` on stderr, before the findings; what was read still prints). The tally always goes to stderr:
#   leased cards: N, lease lost: a, two STARTs: b, lapsed: c, no lease: d
# A comment's session is `created.by.session`; a START is a comment whose first line matches lib.sh START_ERE (`START` or `**START`);
# a lease-lost record is a comment whose first line begins LEASE_LOST_PREFIX (lib.sh). Cards are lane/card folders.
#   <card>: lease lost <comment id> <time>
#   <card>: two STARTs <id> <id> <n>s apart [first session wrote again]   (two sessions, <= --window apart, default 1800;
#       a START without a session is skipped, and so is one whose plan line begins `shaping` (`START: shaping`, bold or not, any case, or the older `START (shaping)`; a handoff to the lead, not a second builder); the tag = the earlier session posted any comment after the later START)
#   <card>: claimed until <ts> is <n>s lapsed   (until more than --grace seconds past, default 900; the whole board
#       counts, flow or block form. A voided claim (until unreadable or over 35 min ahead) is not lapsed: skipped)
#   <card>: started without a lease <comment id> <time>   (a card in a working lane, lib.sh WORKING_LANES (Active, Working), with no `claimed`
#       and no `waiting` (an ask out), whose latest START (not a shaping one) carries a session: the START named.
#       The whole board counts, as for lapsed. Fix: work/scripts/start-card.sh on it, which stakes and posts a fresh START)
# A card is leased when it has a START (a session-less one too), or a lease-lost record, created at or after --since
# (default: always). --first keeps the n leased cards with the earliest such comment, for the tally and the lost and
# two-START findings; lapsed and no lease read every card. Several boards are counted together. Skips .trash, .log, .schema,
# attachments; flow and block front matter, CRLF files. Symlinked boards, lanes and cards are followed. A board is counted
# once however it is spelled (by its real folder); paths print as the caller spelled the first one.
set -u
. "$(dirname "$0")/../../lanework/scripts/lib.sh"
USAGE="usage: lint-leases.sh <board dir>... [--since <ts>] [--first <n>] [--window <s>] [--grace <s>]"
die() { echo "lint-leases.sh: $1" >&2; exit 2; }
# real_time <YYYY-MM-DDTHH:MM:SSZ>: 0 when month, day (leap years too), hour, minute and second all exist
real_time() {
  local y=$((10#${1:0:4})) m=$((10#${1:5:2})) d=$((10#${1:8:2})) dim
  [ "$m" -ge 1 ] && [ "$m" -le 12 ] || return 1
  case $m in 1|3|5|7|8|10|12) dim=31 ;; 4|6|9|11) dim=30 ;; *) if [ $((y % 400)) -eq 0 ] || { [ $((y % 4)) -eq 0 ] && [ $((y % 100)) -ne 0 ]; }; then dim=29; else dim=28; fi ;; esac
  [ "$d" -ge 1 ] && [ "$d" -le "$dim" ] && [ $((10#${1:11:2})) -le 23 ] && [ $((10#${1:14:2})) -le 59 ] && [ $((10#${1:17:2})) -le 59 ]
}
[ $# -ge 1 ] || { echo "$USAGE" >&2; exit 2; }
since=""; first=0; window=1800; grace=900; nb=0
while [ $# -gt 0 ]; do
  case "$1" in
    --since|--first|--window|--grace)
      [ $# -ge 2 ] || die "$1 needs a value"
      case "$1" in
        --since) since=$2; case "$since" in [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z) ;; *) die "--since needs a UTC time like 2026-11-14T15:30:00Z" ;; esac
          real_time "$since" || die "--since names no real time: $since" ;;
        --first) first=$2; case "$first" in ''|*[!0-9]*|0) die "--first needs a positive whole number" ;; esac ;;
        --window) window=$2; case "$window" in ''|*[!0-9]*) die "--window needs whole seconds" ;; esac ;;
        --grace) grace=$2; case "$grace" in ''|*[!0-9]*) die "--grace needs whole seconds" ;; esac ;;
      esac
      shift 2 ;;
    -*) die "unknown argument: $1" ;;
    *)
      b=$1; while [ "${b%/}" != "$b" ] && [ "$b" != "/" ]; do b=${b%/}; done
      [ -e "$b" ] || die "no such path: $1"
      [ -f "$b/index.md" ] || die "not a board (no index.md): $1"
      r=$(cd "$b" && pwd -P) || die "cannot enter: $1"
      i=1; dup=""; while [ "$i" -le "$nb" ]; do eval "[ \"\$real_$i\" = \"\$r\" ]" && dup=1; i=$((i + 1)); done
      if [ -z "$dup" ]; then nb=$((nb + 1)); eval "board_$nb=\$b; real_$nb=\$r"; fi; shift ;;
  esac
done
[ "$nb" -ge 1 ] || { echo "lint-leases.sh: no board given" >&2; echo "$USAGE" >&2; exit 2; }

# Stage 1, one pass over each board's index.md files: C <card> <comment id> <created.at> <session> START|SHAPE|LOST|OTHER,
# K <card> <claimed.until> for a card with `claimed`, N <card> <1 when it has `waiting`, else 0> for every card, A <lane> for a working
# lane. Fields are tab-separated; a missing value is empty.
S1='
function emit(   rel, n, p, card, t, s, a, u, k) {
  if (st < 2) return
  rel = show_name(substr(cur, length(board) + 2))   # escaped before the split: no name part can then hold a newline, which split() on "/" also splits at
  n = split(rel, p, "/")
  card = show_name(show) "/" p[1] "/" p[2]   # printed escaped (lib.sh show_name): a tab or newline would split the records
  if (n == 3 && p[3] == "index.md" && kind == "card" && ltext != "") {
    u = ""
    if (match(ltext, /until:[ \t]*["\x27]?[^",}\x27 \t\n]*/)) { u = substr(ltext, RSTART, RLENGTH); sub(/^until:[ \t]*["\x27]?/, "", u) }
    printf "K\t%s\t%s\n", card, u
  }
  if (n == 3 && p[3] == "index.md" && kind == "card") printf "N\t%s\t%d\n", card, wt
  else if (n == 2 && p[2] == "index.md" && kind == "lane" && title != "" && index(work, "\n" title "\n")) printf "A\t%s\n", show_name(show) "/" p[1]
  else if (n == 5 && p[3] == "comments" && p[5] == "index.md") {
    s = ""
    if (match(ctext, /session:[ \t]*("[^"]*"|\x27[^\x27]*\x27|[^,}\n]*)/)) {
      s = substr(ctext, RSTART, RLENGTH); sub(/^session:[ \t]*/, "", s); gsub(/^["\x27]|["\x27]$/, "", s); sub(/[ \t]+$/, "", s)
    }
    t = ctext; sub(/session:[ \t]*("[^"]*"|\x27[^\x27]*\x27|[^,}\n]*)/, "", t); a = ""
    if (match(t, /(^|[ \t{,\n])at:[ \t]*["\x27]?[0-9]+-[0-9]+-[0-9]+T[0-9:]+(\.[0-9]+)?Z/)) {
      a = substr(t, RSTART, RLENGTH); sub(/^.*at:[ \t]*["\x27]?/, "", a); sub(/\.[0-9]+Z$/, "Z", a)
    }
    k = "OTHER"
    if (first ~ startre) { f2 = tolower(first); k = (f2 ~ shapere) ? "SHAPE" : "START" }
    if (lost != "" && index(first, lost) == 1) k = "LOST"
    printf "C\t%s\t%s\t%s\t%s\t%s\n", card, p[4], a, s, k
  }
}
BEGIN { board = ENVIRON["LL_BOARD"]; show = ENVIRON["LL_SHOW"]; lost = ENVIRON["LL_LOST"]; startre = ENVIRON["LL_START"]; shapere = ENVIRON["LL_SHAPE"]
  work = "\n" ENVIRON["LL_WORK"] "\n" }
{ sub(/\r$/, "") }
FNR == 1 { if (cur != "") emit(); cur = FILENAME; st = ($0 == "---") ? 1 : 0; ctext = ""; ltext = ""; first = ""; kind = ""; key = ""; title = ""; wt = 0; next }
st == 1 {
  if ($0 == "---") { st = 2; next }
  if ($0 ~ /^[^ \t#]/) {
    key = $0; sub(/:.*/, "", key)
    if (key == "kind") { kind = $0; sub(/^kind:[ \t]*/, "", kind); gsub(/["\x27 \t]/, "", kind) }
    if (key == "title") { title = $0; sub(/^title:[ \t]*/, "", title); sub(/[ \t]+$/, "", title)
      if (title ~ /^".*"$/ || title ~ /^\x27.*\x27$/) title = substr(title, 2, length(title) - 2) }
    if (key == "waiting") wt = 1
  }
  if (key == "created") ctext = ctext "\n" $0
  else if (key == "claimed") ltext = ltext "\n" $0
  next
}
st == 2 && $0 ~ /[^ \t]/ { first = $0; st = 3 }
END { if (cur != "") emit() }'

# Stage 2: the four findings from those records, then the tally on stderr.
S2='
function ep(s,   y, m, d, era, yoe, doy, doe) {
  if (s !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z$/) return ""
  y = substr(s, 1, 4) + 0; m = substr(s, 6, 2) + 0; d = substr(s, 9, 2) + 0
  if (m < 1 || m > 12 || d < 1 || d > 31) return ""
  if (m <= 2) y--
  era = int(y / 400); yoe = y - era * 400
  doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
  doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
  return (era * 146097 + doe - 719468) * 86400 + substr(s, 12, 2) * 3600 + substr(s, 15, 2) * 60 + substr(s, 18, 2)
}
BEGIN { FS = "\t"; se = (since == "") ? 0 : ep(since) }
$1 == "C" { c = $2; n = ++cn[c]; if (n == 1) cards[++nc] = c; cid[c, n] = $3; cats[c, n] = $4; cep[c, n] = ep($4); cs[c, n] = $5; ck[c, n] = $6 }
$1 == "K" { kc[++nk] = $2; ku[nk] = $3; kcl[$2] = 1 }
$1 == "N" { nn_c[++nn] = $2; nn_w[$2] = $3 }
$1 == "A" { wl[$2] = 1 }
END {
  for (i = 1; i <= nc; i++) {
    c = cards[i]; q = 0; best = ""
    for (j = 1; j <= cn[c]; j++) {
      t = cep[c, j]
      if ((ck[c, j] == "START" || ck[c, j] == "SHAPE") && t != "" && t >= se) { q++; if (best == "" || t < best) best = t }
      if (ck[c, j] == "LOST" && (since == "" || (t != "" && t >= se))) { q++; if (t == "") t = 9e15; if (best == "" || t < best) best = t }
    }
    if (q) { m++; L[m] = c; LT[m] = best }
  }
  for (i = 2; i <= m; i++) {
    c = L[i]; t = LT[i]; j = i - 1
    while (j >= 1 && (LT[j] > t || (LT[j] == t && L[j] > c))) { L[j + 1] = L[j]; LT[j + 1] = LT[j]; j-- }
    L[j + 1] = c; LT[j + 1] = t
  }
  kept = (first > 0 && m > first) ? first : m
  for (i = 1; i <= kept; i++) {
    c = L[i]; ns = 0
    for (j = 1; j <= cn[c]; j++) {
      t = cep[c, j]
      if (ck[c, j] == "LOST" && (since == "" || (t != "" && t >= se))) { print c ": lease lost " cid[c, j] " " (cats[c, j] == "" ? "-" : cats[c, j]); nl++ }
      if (ck[c, j] == "START" && t != "" && t >= se && cs[c, j] != "") S[++ns] = j
    }
    for (a = 2; a <= ns; a++) {
      j = S[a]; b = a - 1
      while (b >= 1 && (cep[c, S[b]] > cep[c, j] || (cep[c, S[b]] == cep[c, j] && cid[c, S[b]] > cid[c, j]))) { S[b + 1] = S[b]; b-- }
      S[b + 1] = j
    }
    for (a = 2; a <= ns; a++) {
      x = S[a - 1]; y = S[a]
      if (cs[c, x] != cs[c, y] && cep[c, y] - cep[c, x] <= window) {
        tag = ""
        for (j = 1; j <= cn[c]; j++) if (cs[c, j] == cs[c, x] && cep[c, j] != "" && cep[c, j] > cep[c, y]) { tag = " first session wrote again"; break }
        print c ": two STARTs " cid[c, x] " " cid[c, y] " " (cep[c, y] - cep[c, x]) "s apart" tag; n2++; break
      }
    }
    for (a = 1; a <= ns; a++) delete S[a]
  }
  for (i = 1; i <= nk; i++) {
    u = ep(ku[i])
    if (u != "" && now - u > grace) { print kc[i] ": claimed until " ku[i] " is " (now - u) "s lapsed"; nlap++ }
  }
  for (i = 1; i <= nn; i++) {
    c = nn_c[i]; if (nn_w[c] || (c in kcl)) continue
    ln = c; sub(/\/[^\/]*$/, "", ln); if (!(ln in wl)) continue
    bj = 0
    for (j = 1; j <= cn[c]; j++) if (ck[c, j] == "START" && cep[c, j] != "" && (!bj || cep[c, j] > cep[c, bj] || (cep[c, j] == cep[c, bj] && cid[c, j] > cid[c, bj]))) bj = j
    if (bj && cs[c, bj] != "") { print c ": started without a lease " cid[c, bj] " " cats[c, bj]; nu++ }
  }
  printf "leased cards: %d, lease lost: %d, two STARTs: %d, lapsed: %d, no lease: %d\n", kept, nl, n2, nlap, nu > "/dev/stderr"
}'

nowe=$(date -u +%s); unread=0
FD=$(mktemp -d "${TMPDIR:-/tmp}/lw-ll.XXXXXX") || exit 2; trap 'rm -rf "$FD"' EXIT
i=1; while [ "$i" -le "$nb" ]; do eval "b=\$board_$i"; board_index_files "$b" "$FD/$i" || unread=1; i=$((i + 1)); done
out=$(
  i=1
  while [ "$i" -le "$nb" ]; do
    eval "b=\$board_$i"
    [ ! -s "$FD/$i" ] || LL_BOARD="$b" LL_SHOW="$b" LL_LOST="$LEASE_LOST_PREFIX" LL_START="$START_ERE" LL_SHAPE="$SHAPE_ERE" LL_WORK="$WORKING_LANES" xargs -0 awk "$SHOW_NAME_AWK$S1" < "$FD/$i"
    i=$((i + 1))
  done | awk -v since="$since" -v first="$first" -v window="$window" -v grace="$grace" -v now="$nowe" "$S2" | sort
)
[ -z "$out" ] || printf '%s\n' "$out"
[ "$unread" -eq 0 ] || exit 2
[ -z "$out" ] || exit 1
exit 0
