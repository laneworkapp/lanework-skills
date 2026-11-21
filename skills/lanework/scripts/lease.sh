#!/bin/bash
# lease.sh: the card lease. Stake, renew, check and release a card's `claimed`, list the leases on a board, and the
# background timer that renews them. The rules, the exit codes and the record wordings: references/writes.md § Lease.
# usage: lease.sh stake   <board> <card-uuid> --model m [--name n]
#        lease.sh renew   <board> <card-uuid> --model m [--name n]
#        lease.sh check   <board> <card-uuid> --model m [--name n]     prints held | lost | never-held
#        lease.sh release <board> <card-uuid> --model m [--name n] [--force]
#        lease.sh list    <board>        one line per leased card, tab-separated: uuid, holder "name (session)",
#                                        "N min left" | "N min lapsed" | "-" (unreadable until), live | lapsed | voided, title
#        lease.sh _timer  <board> <card-uuid> <session> <claude-pid>      internal: started detached by stake, check, renew
# The holder is CLAUDE_CODE_SESSION_ID (never a flag); stake needs CLAUDE_PID, the session's process, which the timer
# outlives by at most one poll. Exit: 0 ok (check: held), 1 refused (held by another, backed off, nothing to renew), 2 usage / no model / no session id / no CLAUDE_PID /
# not exactly one card with that uuid, 3 lost, 4 check: never held.
# Memory of the cards this session staked: ${TMPDIR:-/tmp}/lanework-lease/<session>/<board key>/<card-uuid>, the board key
# the first 16 hex of the shasum of the board's resolved path (`pwd -P`: a symlink or a trailing slash is the same board), so the
# same card uuid on another copy of the board is never held there. A file in the older <session>/<card-uuid> layout is never
# read. Limit: a board folder renamed or moved under a live lease is a new key, so the memory is forgotten and the old timer exits.
# `claimed` still reads as held, and the next write renews it and starts a new timer. Lapsed and taken over meanwhile, the next write
# lands with no loss record. A lease write lands only on the card as read: that narrows the window against another writer, never
# closes it, because no lock is shared with the app or the other scripts. A write across volumes stages a .lanework-tmp file at the
# board root, which the app's board .gitignore ignores; a board the app has never opened has no .gitignore, so it is not ignored there.
# Each file: key=value lines: board,
# timer pid, CLAUDE_PID, working directory and branch at stake, name, model, last notice seen, state), and a
# <card-uuid>.lost directory once the loss record is posted (mkdir: posted once, whoever finds the loss first).
# Reads git (branch, `git --no-optional-locks status --porcelain`) for the loss record; never writes the repo, stages or commits.
# Test-only knobs, read by tests/smoke.sh: LEASE_TEST_STAKE_WAIT (seconds, default 1), LEASE_TEST_NOTICE_WAIT (120),
# LEASE_TEST_POLL (60), LEASE_TEST_RENEW_EVERY (polls between renewals, 15), LEASE_TEST_WRITE_PAUSE (0: a write's first try waits this
# long between its read and its compare). Fractional seconds are fine.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; SELF="$HERE/lease.sh"
. "$HERE/lib.sh"
USAGE="lease.sh stake|renew|check|release <board> <card-uuid> --model m [--name n] [--force] | lease.sh list <board>"
LEASE_SECS=1800; GUARD_SECS=2100
STAKE_WAIT="${LEASE_TEST_STAKE_WAIT:-1}"; NOTICE_WAIT="${LEASE_TEST_NOTICE_WAIT:-120}"
POLL="${LEASE_TEST_POLL:-60}"; RENEW_EVERY="${LEASE_TEST_RENEW_EVERY:-15}"; WRITE_PAUSE="${LEASE_TEST_WRITE_PAUSE:-0}"
UUID_RE='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
usage() { printf 'lease.sh: %s\nusage: %s\n' "$1" "$USAGE" >&2; exit 2; }
# board_key <resolved board path>: the memory's directory level for that board
board_key() { printf '%s' "$1" | shasum | cut -c1-16; }

# find_card: the card's index.md, resolved fresh. 0 + path; 1 none; 2 several
find_card() {
  local m n; m=$(ls "$BOARD"/*/"$CID"/index.md 2>/dev/null || true); n=$(printf '%s' "$m" | grep -c . || true)
  if [ "$n" -eq 1 ]; then printf '%s' "$m"; return 0; fi
  if [ "$n" -eq 0 ]; then return 1; fi; return 2
}
card_file() { local f; if f=$(find_card); then printf '%s' "$f"; else echo "lease.sh: not exactly one card $CID on $BOARD" >&2; exit 2; fi; }

# read_claim <index.md>: CL_TEXT (the claimed lines, block or flow), CL_SESS, CL_NAME, CL_UNTIL
read_claim() {
  CL_TEXT=$(awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {exit}
    fm && c && /^[ \t]/ {print; next} fm {c=0} fm && /^claimed:/ {c=1; print}' "$1")
  CL_SESS=""; CL_NAME=""; CL_UNTIL=""
  local rs='session:[[:space:]]*"?([^",}[:space:]]*)' rn='name:[[:space:]]*"?([^",}]*)' ru='until:[[:space:]]*"?([^",}[:space:]]*)'
  if [[ $CL_TEXT =~ $rs ]]; then CL_SESS="${BASH_REMATCH[1]}"; fi
  if [[ $CL_TEXT =~ $rn ]]; then CL_NAME="${BASH_REMATCH[1]}"; fi
  if [[ $CL_TEXT =~ $ru ]]; then CL_UNTIL="${BASH_REMATCH[1]}"; fi
}
# status_of: ST = none | live | lapsed | voided (the clock guard: until unreadable or over 35 minutes ahead); UE = until's epoch
status_of() {
  NOWE=$(date -u +%s); UE=""
  if [ -z "$CL_TEXT" ]; then ST=none; return 0; fi
  UE=$(date -j -u -f %Y-%m-%dT%H:%M:%SZ "$CL_UNTIL" +%s 2>/dev/null || true)
  if [ -z "$UE" ] || [ $((UE - NOWE)) -gt "$GUARD_SECS" ]; then ST=voided
  elif [ "$UE" -gt "$NOWE" ]; then ST=live; else ST=lapsed; fi
}

# write_card <set|renew|clear>: rewrite claimed (set, renew: the 3-line block, until 30 min from now; clear: none) and modified whole.
# Each try copies the card as read into the stage and rewrites from that copy; the result moves in only when the card is found
# at the same path and unchanged (compared byte for byte), else the next try reads again. 5 tries, then nothing written: 1.
# Each writes only over the claimed its caller decided on: renew, a copy whose claimed is this session's (else 5); set, the
# claimed text the caller read, SET_CL (else another stake landed: 1, backing off); clear, claimed still CLEAR_SESS's (another
# session's: 1; none: already released, 6). Nothing written in each case. Explicit checks, not set -e: callers run it under || too.
write_card() {
  local f f2 stage now by until="" try
  stage=$(mktemp -d "${TMPDIR:-/tmp}/lease-write.XXXXXX") || return 1
  for try in 1 2 3 4 5; do
    f=$(find_card) || { rm -rf "$stage"; return 1; }
    cp "$f" "$stage/read" 2>/dev/null || continue                      # moved meanwhile: read again
    read_claim "$stage/read"
    case "$1" in
      renew) [ -n "$CL_TEXT" ] && [ "$CL_SESS" = "$SESSION" ] || { rm -rf "$stage"; return 5; } ;;
      set) [ "$CL_TEXT" = "$SET_CL" ] || { rm -rf "$stage"; echo "lease.sh: ${CID:0:8} was staked by ${CL_SESS:-none} meanwhile; backing off" >&2; return 1; } ;;
      clear) [ -n "$CL_TEXT" ] || { rm -rf "$stage"; return 6; }
        [ "$CL_SESS" = "$CLEAR_SESS" ] || { rm -rf "$stage"; echo "lease.sh: ${CID:0:8} is held by ${CL_SESS:-none} meanwhile; nothing released" >&2; return 1; } ;;
    esac
    now=$(now_utc); by=$(by_of "$NAME" "$MODEL" "$SESSION"); until=""; [ "$1" = clear ] || until=$(now_utc "$LEASE_SECS")
    awk -v m="modified: {at: $now, by: $by}" -v set="$1" -v b="  by: $by" -v u="  until: $until" '
      NR == 1 && $0 == "---" { fm = 1; print; next }
      fm && drop && /^[ \t]/ { next }
      fm { drop = 0 }
      fm && $0 == "---" { if (!sm) print m; if (set != "clear") { print "claimed:"; print b; print u }; fm = 0; print; next }
      fm && /^modified:/ { print m; sm = 1; drop = 1; next }
      fm && /^claimed:/ { drop = 1; next }
      { print }' "$stage/read" > "$stage/index.md" || { rm -rf "$stage"; return 1; }
    # the triple-brace guard reads only the lines written here (modified, the claimed block): every other line is copied as read,
    # and valid ones end in `}}}` (a label whose kind carries an icon), as may the body (a JSON example)
    if [ "$(head -1 "$stage/index.md")" != "---" ] || ! stamp_lines_ok "$stage/index.md" modified claimed; then
      rm -rf "$stage"; echo "lease.sh: $f: no frontmatter, or a broken stamp after the rewrite; nothing written" >&2; return 1
    fi
    compact_fm "$stage/index.md" || { rm -rf "$stage"; return 1; }
    [ "$try" != 1 ] || [ "$WRITE_PAUSE" = 0 ] || sleep "$WRITE_PAUSE"
    f2=$(find_card) || continue                                         # fresh, just before the rename
    if [ "$f2" = "$f" ]; then
      # compare and rename in one process, no fork between them: 0 written, 3 changed (read again), 1 failed (nothing written).
      # The stage on another volume than the board (EXDEV): the content is copied to <board>/.lease-write.<card>.<pid>.lanework-tmp,
      # at the board root (no card folder: the app moves loose files there into attachments), compared again, then renamed over
      # the card. That temp file is removed on every failure path and on TERM, INT or HUP; a kill of this script leaves perl to
      # finish. The test pause, first try only, also holds the temp file before its compare.
      local r=0 p=0; [ "$try" != 1 ] || p=$WRITE_PAUSE
      perl -e 'my ($rd, $nw, $f, $tmp, $p) = @ARGV; local $/;
        sub same { open(my $a, "<", $rd) or return 0; open(my $b, "<", $f) or return 0; return <$a> eq <$b> }
        sub fail { unlink $tmp; exit $_[0] }
        same() or exit 3; rename($nw, $f) and exit 0; $!{EXDEV} or exit 1;
        $SIG{$_} = sub { fail(1) } for qw(TERM INT HUP);
        open(my $i, "<", $nw) or exit 1; my $c = <$i>; close $i;
        open(my $o, ">", $tmp) or fail(1); print $o $c or fail(1); close $o or fail(1);
        select(undef, undef, undef, $p) if $p > 0;
        same() or fail(3); rename($tmp, $f) or fail(1); exit 0' \
        "$stage/read" "$stage/index.md" "$f" "$BOARD/.lease-write.$CID.$$.lanework-tmp" "$p" || r=$?
      if [ "$r" = 0 ]; then rm -rf "$stage"; WROTE_UNTIL="$until"; return 0; fi
      [ "$r" = 3 ] || { rm -rf "$stage"; echo "lease.sh: $f: the write failed; nothing written" >&2; return 1; }
    fi
  done
  rm -rf "$stage"; echo "lease.sh: ${CID:0:8} changed under each of 5 tries; nothing written" >&2; return 1
}

# thread <card dir>: "created.at<TAB>first body line" per comment
thread() {
  local f
  for f in "$1"/comments/*/index.md; do
    [ -f "$f" ] || continue
    awk 'NR==1 && $0=="---" {fm=1; next}
      fm && /^created:/ {inc=1} fm && /^[^ \t]/ && !/^created:/ {inc=0}
      fm && inc && match($0, /at:[ \t]*"?[0-9][0-9TZ:.+-]*/) { a = substr($0, RSTART, RLENGTH); sub(/^at:[ \t]*"?/, "", a); inc=0 }
      fm && $0=="---" {fm=0; next}
      !fm && NF {print a "\t" $0; exit}' "$f"
  done
}
# post_record <text>: a record on the card, stamped from the clock in a second no other comment there holds
post_record() {
  local f c now i stage coid
  f=$(find_card) || return 1; c=$(dirname "$f")
  for i in 1 2 3 4 5; do
    now=$(now_utc)
    if ! grep -qs -E "^created:.*[{,][[:space:]]*at:[[:space:]]*[\"']?$now|^[[:space:]]+at:[[:space:]]*[\"']?$now" "$c"/comments/*/index.md; then break; fi
    sleep 1
  done
  stage=$(mktemp -d "${TMPDIR:-/tmp}/lease-comment.XXXXXX"); coid=$(uuid); mkdir "$stage/$coid"
  printf '%s\n' "$1" | comment_file "$stage/$coid/index.md" "$now" "$(by_of "$NAME" "$MODEL" "$SESSION")"
  f=$(find_card) || { rm -rf "$stage"; return 1; }; c=$(dirname "$f")
  mkdir -p "$c/comments" && mv "$stage/$coid" "$c/comments/$coid" || { rm -rf "$stage"; return 1; }
  rm -rf "$stage"
}

# memory: M_* <-> the per-session file
mem_load() {
  M_PID=""; M_CPID=""; M_DIR=""; M_BRANCH=""; M_NAME=""; M_MODEL=""; M_NOTICE=""; M_STATE=""
  [ -f "$MEM" ] || return 0
  local k v
  while IFS='=' read -r k v; do
    case "$k" in pid) M_PID=$v ;; cpid) M_CPID=$v ;; dir) M_DIR=$v ;; branch) M_BRANCH=$v ;; name) M_NAME=$v ;;
      model) M_MODEL=$v ;; notice) M_NOTICE=$v ;; state) M_STATE=$v ;; esac
  done < "$MEM"
}
mem_save() {
  mkdir -p "$MEMD"; local t; t=$(mktemp "$MEMD/.mem.XXXXXX")
  printf 'board=%s\npid=%s\ncpid=%s\ndir=%s\nbranch=%s\nname=%s\nmodel=%s\nnotice=%s\nstate=%s\n' \
    "$BOARD" "$M_PID" "$M_CPID" "$M_DIR" "$M_BRANCH" "$M_NAME" "$M_MODEL" "$M_NOTICE" "$M_STATE" > "$t"
  mv "$t" "$MEM"
}
# mem_new: the work-in-flight facts as of now (the caller's directory and branch)
mem_new() {
  M_PID=""; M_CPID="${CLAUDE_PID:-}"; M_DIR=$(pwd -P); M_NAME=$NAME; M_MODEL=$MODEL; M_NOTICE=$(now_utc); M_STATE=held
  # the branch (an unborn one too), else a detached head's sha, else none
  M_BRANCH=$(git -C "$M_DIR" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$M_DIR" rev-parse --short HEAD 2>/dev/null || true)
  [ -n "$M_BRANCH" ] || M_BRANCH=none
  mem_save
}
# is_timer <pid>: this card's timer, matched by board and card uuid, so a reused pid never names another card's
is_timer() { [ -n "$1" ] && kill -0 "$1" 2>/dev/null && ps -ww -p "$1" -o command= 2>/dev/null | grep -q -F "lease.sh _timer $BOARD $CID "; }
stop_timer() { if is_timer "$M_PID"; then kill "$M_PID" 2>/dev/null || true; fi; }
# ensure_timer: start a timer unless this card's is running; needs a live CLAUDE_PID (the environment's, else the one saved at stake)
ensure_timer() {
  local cp="${CLAUDE_PID:-$M_CPID}"
  if is_timer "$M_PID"; then return 0; fi
  if [ -z "$cp" ] || ! kill -0 "$cp" 2>/dev/null; then echo "lease.sh: no live CLAUDE_PID; no timer for ${CID:0:8}" >&2; return 0; fi
  nohup "$SELF" _timer "$BOARD" "$CID" "$SESSION" "$cp" </dev/null >/dev/null 2>&1 &
  M_PID=$!; M_CPID=$cp; mem_save
}
# lose <the other session, or none>: once per card and session, the loss record, and the memory marked lost.
# The .lost directory is the once-guard (mkdir: one caller wins). A record that fails to land takes the mark back, so the
# next call tries again: never lost without the record.
lose() {
  mem_load
  mkdir "$MEM.lost" 2>/dev/null || return 0
  NAME=${M_NAME:-$NAME}; MODEL=${M_MODEL:-$MODEL}
  local files=""
  if [ -n "$M_DIR" ] && [ -d "$M_DIR" ]; then
    files=$(git --no-optional-locks -C "$M_DIR" status --porcelain 2>/dev/null | cut -c4- | paste -sd, - | sed 's/,/, /g' || true)
  fi
  if ! post_record "$LEASE_LOST_PREFIX session $SESSION no longer holds this card; session $1 does. Work left in place: branch ${M_BRANCH:-none}, directory ${M_DIR:-unknown}, files touched: ${files:-none}. This session writes this card no more."; then
    rmdir "$MEM.lost" 2>/dev/null || true; echo "lease.sh: the loss record on ${CID:0:8} did not land" >&2; return 1
  fi
  M_STATE=lost; mem_save
}
# own_held: the lease is this session's: renew it when lapsed or voided (or always, with "renew"), keep the memory and the timer.
# claimed no longer this session's by the write (5): read the card again and decide once more (decide)
own_held() {
  local rc=0
  if [ "${1:-}" = renew ] || [ "$ST" != live ]; then write_card renew || rc=$?; fi
  if [ "$rc" = 5 ]; then REDO=$((REDO + 1)); [ "$REDO" -le 3 ] || { echo "lease.sh: ${CID:0:8} kept changing; nothing written" >&2; exit 1; }
    F=$(card_file); read_claim "$F"; status_of; decide; exit 0; fi
  [ "$rc" = 0 ] || exit 1
  mem_load; [ -f "$MEM" ] || mem_new
  ensure_timer
}

timer() {
  local f n=0 na
  while :; do
    sleep "$POLL"; n=$((n + 1))
    kill -0 "$TCPID" 2>/dev/null || exit 0
    [ -f "$MEM" ] && [ ! -d "$MEM.lost" ] || exit 0
    mem_load; [ -z "$M_PID" ] || [ "$M_PID" = "$$" ] || exit 0   # released, or a newer timer took over; empty: not saved yet
    NAME=${M_NAME:-claude}; MODEL=${M_MODEL:-unknown}
    f=$(find_card) || exit 0
    read_claim "$f"; [ -n "$CL_TEXT" ] || exit 0     # released
    if [ "$CL_SESS" != "$SESSION" ]; then lose "$CL_SESS" || true; exit 0; fi
    na=$(thread "$(dirname "$f")" | awk -F'\t' -v s="$SESSION" 'index($2, "**Takeover notice**:") == 1 && index($2, "from session " s " at ") {print $1}' | sort | tail -1)
    if [ -n "$na" ] && [[ "$na" > "$M_NOTICE" ]]; then
      M_PID=$$; M_NOTICE=$na; mem_save; write_card renew || true; n=0; continue   # renew 5: the next poll finds the loss or release
    fi
    if [ $((n % RENEW_EVERY)) -eq 0 ]; then write_card renew || true; fi
  done
}

list() {
  local f t mins
  for f in "$BOARD"/*/*/index.md; do
    [ "$(fm_value "$f" kind)" = card ] || continue
    read_claim "$f"; [ -n "$CL_TEXT" ] || continue
    status_of; t=$(strip_quotes "$(fm_value "$f" title)")
    if [ -z "$UE" ]; then mins="-"
    elif [ "$UE" -gt "$NOWE" ]; then mins="$(( (UE - NOWE) / 60 )) min left"
    else mins="$(( (NOWE - UE) / 60 )) min lapsed"; fi
    printf '%s\t%s (%s)\t%s\t%s\t%s\n' "$(basename "$(dirname "$f")")" "${CL_NAME:-?}" "${CL_SESS:-?}" "$mins" "$ST" "$t"   # title last: free text
  done
}

SUB="${1:-}"; [ $# -gt 0 ] && shift
case "$SUB" in
  list) [ $# -eq 1 ] || usage "list takes one board"; BOARD="$1"; [ -f "$BOARD/index.md" ] || usage "not a board: $BOARD"; list; exit 0 ;;
  _timer)
    [ $# -eq 4 ] || exit 2; BOARD="$1"; CID="$2"; SESSION="$3"; TCPID="$4"; MODEL=""; NAME=claude
    R="${TMPDIR:-/tmp}"; MEMD="${R%/}/lanework-lease/$SESSION/$(board_key "$BOARD")"; MEM="$MEMD/$CID"; timer; exit 0 ;;
  stake|renew|check|release) ;;
  *) usage "unknown subcommand: ${SUB:-none}" ;;
esac
[ $# -ge 2 ] || usage "$SUB needs <board> <card-uuid>"
BOARD="$1"; CID="$2"; shift 2; MODEL=""; NAME=claude; FORCE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --model) [ $# -ge 2 ] || usage "--model needs a value"; MODEL="$2"; shift 2 ;;
    --name)  [ $# -ge 2 ] || usage "--name needs a value"; NAME="$2"; shift 2 ;;
    --force) [ "$SUB" = release ] || usage "--force is release's"; FORCE=1; shift ;;
    *) usage "unknown argument: $1" ;;
  esac
done
require_model lease.sh "$USAGE"
SESSION="${CLAUDE_CODE_SESSION_ID:-}"
[ -n "$SESSION" ] || usage "no CLAUDE_CODE_SESSION_ID: no session id, no lease"
case "$SESSION" in */*|*\"*|*[[:space:]]*) usage "session id with a slash, quote or space: $SESSION" ;; esac
[ "$SUB" != stake ] || [ -n "${CLAUDE_PID:-}" ] || usage "no CLAUDE_PID: the timer exits with the session's process"
[[ "$CID" =~ $UUID_RE ]] || usage "not a lowercase card uuid: $CID"
[ -f "$BOARD/index.md" ] || usage "not a board: $BOARD"
BOARD=$(cd "$BOARD" && pwd -P)
R="${TMPDIR:-/tmp}"; MEMD="${R%/}/lanework-lease/$SESSION/$(board_key "$BOARD")"; MEM="$MEMD/$CID"
# decide: the subcommand on the card as read (F, CL_*, ST); every branch exits. own_held calls it again on a changed claimed
decide() {
case "$SUB" in
stake)
  if [ -d "$MEM.lost" ]; then echo "lease.sh: this session lost ${CID:0:8} and writes it no more" >&2; exit 3; fi
  if [ "$ST" != none ] && [ "$CL_SESS" = "$SESSION" ]; then own_held renew; echo "held $CID until $WROTE_UNTIL"; exit 0; fi
  # staked here (remembered), and claimed is gone or another session's (live or lapsed): a loss, never a takeover
  if [ -f "$MEM" ]; then lose "${CL_SESS:-none}" || true; echo "lease.sh: lost ${CID:0:8} to session ${CL_SESS:-none}" >&2; exit 3; fi
  IGNORED=""
  case "$ST" in
    voided) IGNORED="${CL_UNTIL:-none}"; IGN_NOW=$(now_utc) ;;
    live) echo "lease.sh: ${CID:0:8} is held by session $CL_SESS until $CL_UNTIL" >&2; exit 1 ;;
    lapsed)
      OLD_S="$CL_SESS"; OLD_U="$CL_UNTIL"
      PRIOR=$(thread "$(dirname "$F")" | awk -F'\t' 'index($2, "**Lease lost**") || $2 ~ /^(\*\*)?START/' | sort | tail -1 | cut -f2-)
      [ -z "$PRIOR" ] || echo "prior: $PRIOR"
      W=${NOTICE_WAIT%.*}; [ -n "$W" ] || W=0
      post_record "**Takeover notice**: session $SESSION takes this card from session $OLD_S at $(now_utc "$W") unless the lease is renewed first. It lapsed at $OLD_U."
      sleep "$NOTICE_WAIT"
      F=$(card_file); read_claim "$F"
      if [ "$CL_SESS" != "$OLD_S" ] || [ "$CL_UNTIL" != "$OLD_U" ]; then
        echo "lease.sh: session ${CL_SESS:-none} answered the notice on ${CID:0:8}; backing off" >&2; exit 1
      fi ;;
  esac
  SET_CL="$CL_TEXT"; write_card set
  sleep "$STAKE_WAIT"
  F=$(card_file); read_claim "$F"
  if [ "$CL_SESS" != "$SESSION" ]; then echo "lease.sh: session ${CL_SESS:-none} staked ${CID:0:8} first; backing off" >&2; exit 1; fi
  [ -z "$IGNORED" ] || post_record "**Lease ignored**: until $IGNORED was over 35 minutes ahead of $IGN_NOW, so the card was staked as free."
  mem_new; ensure_timer
  echo "held $CID until $WROTE_UNTIL" ;;
renew)
  if [ -d "$MEM.lost" ]; then echo "lease.sh: this session lost ${CID:0:8}" >&2; exit 3; fi
  if [ "$ST" != none ] && [ "$CL_SESS" = "$SESSION" ]; then own_held renew; echo "held $CID until $WROTE_UNTIL"; exit 0; fi
  if [ -f "$MEM" ]; then lose "${CL_SESS:-none}" || true; echo "lease.sh: lost ${CID:0:8} to session ${CL_SESS:-none}" >&2; exit 3; fi
  if [ "$ST" = none ]; then echo "lease.sh: no lease on ${CID:0:8} to renew" >&2; exit 1; fi
  echo "lease.sh: ${CID:0:8} is session $CL_SESS's, not this session's" >&2; exit 3 ;;
check)
  if [ -d "$MEM.lost" ]; then echo lost; exit 3; fi
  if [ "$ST" != none ] && [ "$CL_SESS" = "$SESSION" ]; then own_held; echo held; exit 0; fi
  if [ -f "$MEM" ]; then lose "${CL_SESS:-none}" || true; echo lost; exit 3; fi
  echo never-held; exit 4 ;;
release)
  if [ -n "$FORCE" ] && [ "$ST" != none ] && [ "$CL_SESS" != "$SESSION" ]; then
    RC=0; FS="$CL_SESS"; FU="$CL_UNTIL"; CLEAR_SESS="$CL_SESS"; write_card clear || RC=$?
    case "$RC" in
      0) post_record "**Lease released by force** on the owner's word: session $FS held it until $FU." ;;
      6) echo "lease.sh: ${CID:0:8} was already released; nothing released by force" ;;
      *) exit 1 ;;
    esac
    exit 0
  fi
  if [ -d "$MEM.lost" ]; then echo "lease.sh: this session lost ${CID:0:8} and writes it no more" >&2; exit 3; fi
  if [ "$ST" != none ] && [ "$CL_SESS" != "$SESSION" ]; then
    echo "lease.sh: ${CID:0:8} is held by session $CL_SESS; --force on the owner's word only" >&2; exit 1
  fi
  mem_load; stop_timer
  RC=0; CLEAR_SESS="$SESSION"; [ "$ST" = none ] || write_card clear || RC=$?
  [ "$RC" = 0 ] || [ "$RC" = 6 ] || exit 1          # another session's claim: nothing released, the memory kept for the loss
  rm -f "$MEM" ;;
esac
exit 0
}
REDO=0; F=$(card_file); read_claim "$F"; status_of; decide
