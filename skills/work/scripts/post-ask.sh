#!/bin/bash
# post-ask.sh: post one ask and set the card's `waiting` to it, in one step.
# usage: post-ask.sh <board> <card-uuid> --body F --model m --for <handle|anyone> [--name n] [--session s] [--in-reply-to u]
# F = a bare ask body (work/templates/ask.md). --for is required, no default: the handle the ask
# addresses, which must be on the body's first line as @<handle>. The body is linted with lint-ask.sh
# twice: against the board, and with no board (so an ask to a person other than the guide's handle
# is linted too). Then waits until the clock is at least one second past the card's newest comment
# (a record posted just before), posts through post-comment.sh (clock stamp, same-second refusal),
# and rewrites the card's frontmatter: `waiting: {for: <handle>, since: <the ask's created.at>,
# comment: <the ask's uuid>}` (replacing any earlier `waiting`) and `modified` whole with the
# caller's `by`. Staged outside the board, then `mv`. Prints the ask's uuid. One handle only: a list
# (`for: [a, b]`) is written by hand.
# Exit 2, nothing written: no model, no --body, no --for, a bad flag or handle, no card or several.
# Exit 1, nothing written: not a board, not a lowercase uuid, the body fails lint or lacks @<handle>
# on line 1, the newest comment over 30 s ahead of the clock, post-comment.sh refused. Exit 3, nothing
# written but the Lease lost record: post-comment.sh found this session's lease on the card lost
# (lanework/references/writes.md § Lease); `waiting` untouched. Exit 1 after the ask landed: the card
# could not be restamped (set `waiting` by hand).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
HERE="$(dirname "${BASH_SOURCE[0]}")"
USAGE="post-ask.sh <board> <card-uuid> --body F --model m --for <handle|anyone> [--name n] [--session s] [--in-reply-to u]"
[ $# -ge 2 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; CID="$2"; shift 2
MODEL=""; NAME="claude"; SESSION=""; BODY=""; REPLY=""; FOR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --body)        need_value "$@"; BODY="$2"; shift 2 ;;
    --model)       need_value "$@"; MODEL="$2"; shift 2 ;;
    --for)         need_value "$@"; FOR="$2"; shift 2 ;;
    --name)        need_value "$@"; NAME="$2"; shift 2 ;;
    --session)     need_value "$@"; SESSION="$2"; shift 2 ;;
    --in-reply-to) need_value "$@"; REPLY="$2"; shift 2 ;;
    *) echo "post-ask.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model post-ask.sh "$USAGE"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
[ -n "$BODY" ] || { echo "post-ask.sh: no --body" >&2; echo "usage: $USAGE" >&2; exit 2; }
[ -n "$FOR" ] || { echo "post-ask.sh: no --for: name the handle the ask addresses (anyone, or a person's)" >&2; echo "usage: $USAGE" >&2; exit 2; }
[[ "$FOR" =~ ^[A-Za-z0-9_-]+$ ]] || { echo "post-ask.sh: --for is one handle, no @: $FOR" >&2; exit 2; }
UUID_RE='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
[ -f "$BOARD/index.md" ] || { echo "post-ask.sh: not a board: $BOARD" >&2; exit 1; }
[[ "$CID" =~ $UUID_RE ]] || { echo "post-ask.sh: not a lowercase card uuid: $CID" >&2; exit 1; }
[ -r "$BODY" ] || { echo "post-ask.sh: cannot read --body $BODY" >&2; exit 1; }
card() {
  local m n; m=$(ls "$BOARD"/*/"$CID"/index.md 2>/dev/null || true); n=$(printf '%s' "$m" | grep -c . || true)
  [ "$n" -eq 1 ] || { echo "post-ask.sh: $n cards $CID on the board; need exactly one" >&2; exit 2; }
  dirname "$m"
}
CARD=$(card)

first=$(grep -v '^[[:space:]]*$' "$BODY" | head -1 || true)
printf '%s\n' "$first" | grep -q -i -E "(^|[^[:alnum:]_])@$FOR([^[:alnum:]_-]|$)" || { echo "post-ask.sh: the body's first line does not address @$FOR; nothing written" >&2; exit 1; }
for b in "$BOARD" ""; do
  "$HERE/lint-ask.sh" "$BODY" ${b:+"$b"} || { echo "post-ask.sh: the body fails lint-ask.sh; nothing written" >&2; exit 1; }
done

# newest: the latest created.at second among the card's comments (flow or block form), as epoch; 0 when none
newest() {
  local f t="" s
  for f in "$(card)"/comments/*/index.md; do   # an unmatched glob stays literal: the -f test skips it
    [ -f "$f" ] || continue
    s=$(awk '
      FNR == 1 && $0 ~ /^---[ \t\r]*$/ { fm = 1; next }
      fm && $0 ~ /^---[ \t\r]*$/ { exit }
      fm && /^[A-Za-z-]+:/ { key = $0; sub(/:.*/, "", key) }
      fm && key == "created" && match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z/) { print substr($0, RSTART, RLENGTH); exit }' "$f")
    if [ -n "$s" ] && [[ "$s" > "$t" ]]; then t="$s"; fi
  done
  if [ -n "$t" ]; then date -j -u -f %Y-%m-%dT%H:%M:%SZ "$t" +%s 2>/dev/null || echo 0; else echo 0; fi
}
N=$(newest)
[ $((N - $(date -u +%s))) -le 30 ] || { echo "post-ask.sh: the card's newest comment is over 30 s ahead of the clock; restamp it first" >&2; exit 1; }
while [ "$(date -u +%s)" -le "$N" ]; do sleep 0.1; done

COID=$("$HERE/post-comment.sh" "$BOARD" "$CID" --body "$BODY" --model "$MODEL" --name "$NAME" ${SESSION:+--session "$SESSION"} ${REPLY:+--in-reply-to "$REPLY"}) \
  || { rc=$?; if [ "$rc" -eq 3 ]; then echo "post-ask.sh: the lease on ${CID:0:8} is lost; nothing written, waiting untouched" >&2; exit 3; fi
       echo "post-ask.sh: post-comment.sh refused the ask; nothing written" >&2; exit 1; }

CARD=$(card)
SINCE=$(sed -n 's/^created: *{at: \([^,}]*\).*/\1/p' "$CARD/comments/$COID/index.md" | head -1)
BY=$(by_of "$NAME" "$MODEL" "$SESSION"); NOW=$(now_utc)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/work-ask.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
# frontmatter only: any waiting (and its block lines) dropped, modified rewritten whole, the new waiting just before it
LW_W="waiting: {for: $FOR, since: $SINCE, comment: $COID}" LW_M="modified: {at: $NOW, by: $BY}" awk '   # ENVIRON, not -v: awk -v interprets backslash escapes in a stamp value
  BEGIN { w = ENVIRON["LW_W"]; m = ENVIRON["LW_M"] }
  NR == 1 && $0 == "---" { fm = 1; print; next }
  fm && drop && /^[ \t]/ { next }
  fm { drop = 0 }
  fm && $0 == "---" { if (!sm) { print w; print m }; fm = 0; print; next }
  fm && /^waiting:/ { drop = 1; next }
  fm && /^modified:/ { print w; print m; sm = 1; drop = 1; next }
  { print }' "$CARD/index.md" > "$STAGE/index.md"
if [ -z "$SINCE" ] || ! stamp_lines_ok "$STAGE/index.md" waiting modified || [ "$(head -1 "$STAGE/index.md")" != "---" ]; then
  echo "post-ask.sh: ask $COID landed, but the card could not be restamped; set waiting by hand" >&2; exit 1
fi
mv "$STAGE/index.md" "$(card)/index.md"
printf '%s\n' "$COID"
