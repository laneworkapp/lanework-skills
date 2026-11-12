#!/bin/bash
# post-comment.sh: post one comment with a stamp taken from the clock.
# usage: post-comment.sh <board> <card-uuid> --body F --model m [--name n] [--session s] [--in-reply-to u] [--ahead 0-30]
# F = a bare body, no frontmatter. Writes the comment (created, modified, by from `now_utc <ahead>`),
# staged outside the board, card found by its `<uuid>/index.md` (exactly one) just before the `mv`.
# Prints the new comment uuid (an ask's `waiting.comment` needs it). An ask goes one second after
# its record: --ahead 1. --ahead is capped at 30 s (under lint-stamps.sh's 60 s slack).
# Refuses (exit 1, nothing written) when a comment already on the card carries the same second (a
# check, not a lock: posters started together can still collide) or the body fails lint-ask.sh.
# Exit 2, nothing written: no model, bad flag or --ahead, no card or several with that uuid.
# Posting never restamps the card.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="post-comment.sh <board> <card-uuid> --body F --model m [--name n] [--session s] [--in-reply-to u] [--ahead 0-30]"
BOARD="${1:?usage: $USAGE}"; CID="${2:?usage: $USAGE}"; shift 2
MODEL=""; NAME="claude"; SESSION=""; BODY=""; REPLY=""; AHEAD=0
while [ $# -gt 0 ]; do
  case "$1" in
    --body)        BODY="${2:?--body needs a value}"; shift 2 ;;
    --model)       MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)        NAME="${2:?--name needs a value}"; shift 2 ;;
    --session)     SESSION="${2:?--session needs a value}"; shift 2 ;;
    --in-reply-to) REPLY="${2:?--in-reply-to needs a value}"; shift 2 ;;
    --ahead)       [ $# -ge 2 ] || { echo "post-comment.sh: --ahead needs a value" >&2; exit 2; }; AHEAD="$2"; shift 2 ;;
    *) echo "post-comment.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model post-comment.sh "$USAGE"
[ -n "$BODY" ] || { echo "post-comment.sh: no --body" >&2; echo "usage: $USAGE" >&2; exit 2; }
case "$AHEAD" in ''|*[!0-9]*) echo "post-comment.sh: --ahead needs whole seconds, 0-30" >&2; exit 2 ;; esac
[ "$AHEAD" -le 30 ] || { echo "post-comment.sh: --ahead $AHEAD is over the 30 s cap: a stamp comes from the clock" >&2; exit 2; }
UUID_RE='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
[ -f "$BOARD/index.md" ] || { echo "post-comment.sh: not a board: $BOARD" >&2; exit 1; }
[[ "$CID" =~ $UUID_RE ]] || { echo "post-comment.sh: not a lowercase card uuid: $CID" >&2; exit 1; }
[ -z "$REPLY" ] || [[ "$REPLY" =~ $UUID_RE ]] || { echo "post-comment.sh: --in-reply-to is not a lowercase comment uuid: $REPLY" >&2; exit 1; }
[ -r "$BODY" ] || { echo "post-comment.sh: cannot read --body $BODY" >&2; exit 1; }
[ "$(head -1 "$BODY")" != "---" ] || { echo "post-comment.sh: --body is a bare body: no frontmatter" >&2; exit 1; }
# card: the card folder, found by its index.md; exit 2 unless exactly one matches
card() {
  local m n; m=$(ls "$BOARD"/*/"$CID"/index.md 2>/dev/null || true); n=$(printf '%s' "$m" | grep -c . || true)
  [ "$n" -eq 1 ] || { echo "post-comment.sh: $n cards $CID on the board; need exactly one" >&2; exit 2; }
  dirname "$m"
}
CARD=$(card)

NOW=$(now_utc "$AHEAD"); BY=$(by_of "$NAME" "$MODEL" "$SESSION")
# created.at in flow form (any spacing, by before or after at) or in block form
if grep -qs -E "^created:.*[{,][[:space:]]*at:[[:space:]]*[\"']?$NOW|^[[:space:]]+at:[[:space:]]*[\"']?$NOW" "$CARD"/comments/*/index.md; then
  echo "post-comment.sh: a comment on this card already has $NOW; one distinct second per comment: pass --ahead 1" >&2; exit 1
fi
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/work-comment.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
COID=$(uuid); mkdir -p "$STAGE/$COID"
comment_file "$STAGE/$COID/index.md" "$NOW" "$BY" "$REPLY" < "$BODY"
"$(dirname "${BASH_SOURCE[0]}")/lint-ask.sh" "$STAGE/$COID/index.md" "$BOARD" || { echo "post-comment.sh: the body fails lint-ask.sh; nothing written" >&2; exit 1; }

C=$(card)
[ -d "$C/comments" ] || mkdir "$C/comments"; mv "$STAGE/$COID" "$C/comments/$COID"
printf '%s\n' "$COID"
