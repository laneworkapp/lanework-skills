#!/bin/bash
# state.sh: a dispatch session's state, in files. The only writer of <dir>.
# usage: state.sh <dir> <command> [args]
#
#   init <board>...          record the boards watched (adds to any already recorded)
#   boards                   print them, one per line
#   claim <card> <event>     card idle -> mark it in flight, print `spawn`
#                            in flight -> queue <event> for it, print `queued`
#                            in flight under a build lead -> queue it too, print `relay <agent-id>`
#   tag <card> <agent-id> [lead]   name the handler holding <card>; `lead` = a build lead
#   finish <card>            the handler is done. Prints the card's queued events and clears the
#                            queue; any printed = the card stays in flight for one follow-up
#                            handler. None = the card leaves the in-flight set.
#   self <path>...           register handler-written paths (absolute) in the self-writes registry
#   is-self <path>           exit 0 when <path> was registered within the TTL
#   prune                    drop registry entries older than the TTL
#   exclude <board> <lane-uuid>     record a lane a handler reported out of scope
#   is-excluded <board> <lane-uuid> exit 0 when recorded
#   show                     the whole state, for a re-arm after /clear
#
# <card> is a card uuid, or `bulk:<Board>.lanework` for a BULK diagnosis.
# Files: boards, inflight (<card> TAB <epoch> TAB <agent-id or -> TAB <role>), queue/<card>,
# self (<epoch> TAB <path>), excluded (<board> TAB <lane-uuid>).
# DISPATCH_TTL: registry lifetime in seconds, default 300. DISPATCH_NOW: the clock, for tests.
set -euo pipefail
USAGE="usage: state.sh <dir> init|boards|claim|tag|finish|self|is-self|prune|exclude|is-excluded|show [args]"
DIR="${1:-}"; CMD="${2:-}"
[ -n "$DIR" ] && [ -n "$CMD" ] || { echo "$USAGE" >&2; exit 2; }
shift 2
TTL="${DISPATCH_TTL:-300}"
now() { printf '%s' "${DISPATCH_NOW:-$(date +%s)}"; }
mkdir -p "$DIR/queue"; touch "$DIR/boards" "$DIR/inflight" "$DIR/self" "$DIR/excluded"

# one writer at a time: a mkdir lock, waited on for up to 5s
lock() { local i; for i in $(seq 1 50); do mkdir "$DIR/.lock" 2>/dev/null && { trap 'rmdir "$DIR/.lock" 2>/dev/null || true' EXIT; return 0; }; sleep 0.1; done
  echo "state.sh: $DIR/.lock held for 5s; remove it if no dispatch command is running" >&2; exit 1; }
need() { [ "$1" -ge "$2" ] || { echo "$USAGE" >&2; exit 2; }; }
safe() { case "$1" in ''|*/*|.*) echo "state.sh: bad card key: $1" >&2; exit 2 ;; esac; }
# rewrite <file> <awk program> [awk -v args...]: filter a file in place, atomically
squeeze() { printf '%s' "$1" | tr -s /; }   # a/b//c and a/b/c name one path
has_excluded() { B="$(squeeze "${1%/}")" awk -F'\t' -v l="$2" '$1 == ENVIRON["B"] && $2 == l { f = 1 } END { exit !f }' "$DIR/excluded"; }
rewrite() { local f="$1" p="$2"; shift 2; awk "$@" "$p" "$f" > "$f.tmp"; mv "$f.tmp" "$f"; }

case "$CMD" in
  init)
    need $# 1; lock
    for b in "$@"; do b="$(squeeze "${b%/}")"; grep -qxF -- "$b" "$DIR/boards" || printf '%s\n' "$b" >> "$DIR/boards"; done ;;
  boards) cat "$DIR/boards" ;;
  claim)
    need $# 2; safe "$1"; lock
    row=$(awk -F'\t' -v k="$1" '$1 == k' "$DIR/inflight")
    if [ -z "$row" ]; then printf '%s\t%s\t-\thandler\n' "$1" "$(now)" >> "$DIR/inflight"; echo spawn
    else
      printf '%s\n' "$2" >> "$DIR/queue/$1"   # a relayed event too: the follow-up answers what the lead did not
      if [ "$(cut -f4 <<<"$row")" = lead ]; then echo "relay $(cut -f3 <<<"$row")"; else echo queued; fi
    fi ;;
  tag)
    need $# 2; safe "$1"; lock
    awk -F'\t' -v k="$1" '$1 == k { f = 1 } END { exit !f }' "$DIR/inflight" || { echo "state.sh: $1 is not in flight" >&2; exit 1; }
    rewrite "$DIR/inflight" 'BEGIN { FS = OFS = "\t" } $1 == k { $3 = a; $4 = r } { print }' -v k="$1" -v a="$2" -v r="${3:-handler}" ;;
  finish)
    need $# 1; safe "$1"; lock
    q="$DIR/queue/$1"
    if [ -s "$q" ]; then
      cat "$q"; rm -f "$q"
      rewrite "$DIR/inflight" 'BEGIN { FS = OFS = "\t" } $1 == k { $2 = t; $3 = "-"; $4 = "handler" } { print }' -v k="$1" -v t="$(now)"
    else
      rm -f "$q"; rewrite "$DIR/inflight" 'BEGIN { FS = "\t" } $1 != k' -v k="$1"
    fi ;;
  self)
    need $# 1; lock; t=$(now)
    for p in "$@"; do printf '%s\t%s\n' "$t" "$(squeeze "$p")" >> "$DIR/self"; done ;;
  is-self)
    need $# 1
    P="$(squeeze "$1")" awk -F'\t' -v t="$(now)" -v ttl="$TTL" '$2 == ENVIRON["P"] && t - $1 <= ttl { f = 1 } END { exit !f }' "$DIR/self" ;;
  prune)
    lock; rewrite "$DIR/self" 'BEGIN { FS = "\t" } t - $1 <= ttl' -v t="$(now)" -v ttl="$TTL" ;;
  exclude)
    need $# 2; lock
    has_excluded "$1" "$2" || printf '%s\t%s\n' "$(squeeze "${1%/}")" "$2" >> "$DIR/excluded" ;;
  is-excluded)
    need $# 2; has_excluded "$1" "$2" ;;
  show)
    for f in boards inflight excluded; do echo "== $f"; cat "$DIR/$f"; done
    echo "== queue"; for q in "$DIR"/queue/*; do [ -e "$q" ] && printf '%s: %s queued\n' "${q##*/}" "$(wc -l < "$q" | tr -d ' ')"; done; true ;;
  *) echo "$USAGE" >&2; exit 2 ;;
esac
