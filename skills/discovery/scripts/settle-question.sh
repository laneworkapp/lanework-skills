#!/bin/bash
# settle-question.sh: record a ruling on a question card and move it.
# usage: settle-question.sh <board> <card-uuid> --ruling F [--to settled|parked] \
#          [--record F [--reply <ask-uuid>]] --model m [--name n] [--session s]
# Appends `## Ruling` + the --ruling text (templates/ruling.md), drops `waiting`, restamps,
# posts --record (a `>` quote line and a `**Given**` line, else exit 2) as a comment (in reply to --reply, default the card's
# `waiting.comment`), moves the card to the bottom of Settled or Parked. --ruling and --record are written with LF line ends.
# `waiting` set: the staged card and its comments are run through work/scripts/lint-waiting-clears.sh first; a NO-QUOTE
# (no owner comment answers the ask, and no record in reply to it) = exit 1, nothing written.
# Staged outside the board; the card path is re-resolved just before landing.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
LINT_CLEARS="$LIB_DIR/../../work/scripts/lint-waiting-clears.sh"

BOARD="${1:?usage: settle-question.sh <board> <card-uuid> --ruling F [...]}"
CID="${2:?usage: settle-question.sh <board> <card-uuid> --ruling F [...]}"
shift 2
TO="settled"; REPLY=""; RULING=""; RECORD=""
MODEL=""; NAME="claude"; SESSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --to)      TO="${2:?}"; shift 2 ;;
    --reply)   REPLY="${2:?}"; shift 2 ;;
    --ruling)  RULING="${2:?}"; shift 2 ;;
    --record)  RECORD="${2:?}"; shift 2 ;;
    --model)   MODEL="${2:?}"; shift 2 ;;
    --name)    NAME="${2:?}"; shift 2 ;;
    --session) SESSION="${2:?}"; shift 2 ;;
    *) echo "settle-question.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
require_model settle-question.sh "settle-question.sh <board> <card-uuid> --ruling F --model m [...]"
[ -r "${RULING:-}" ] || { echo "settle-question.sh: --ruling must name a readable file" >&2; exit 2; }
[ -z "$RECORD" ] || [ -r "$RECORD" ] || { echo "settle-question.sh: --record must name a readable file" >&2; exit 2; }
if [ -n "$RECORD" ]; then
  grep -q '^>' "$RECORD" && grep -q '\*\*Given\*\*' "$RECORD" || { echo "settle-question.sh: --record needs a '>' quote line and a '**Given**: <where>, <date>' line (templates/ruling.md)" >&2; exit 2; }
fi
case "$TO" in settled) LANE_TITLE=Settled ;; parked) LANE_TITLE=Parked ;; *) echo "settle-question.sh: --to is settled or parked" >&2; exit 2 ;; esac
DEST=$(lane_by_title "$BOARD" "$LANE_TITLE") || { echo "settle-question.sh: no lane titled $LANE_TITLE" >&2; exit 1; }

find_card() { ls -d "$BOARD"/*/"$CID" 2>/dev/null | head -1 || true; }
CARD=$(find_card)
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] || { echo "settle-question.sh: no card $CID on the board" >&2; exit 1; }

# waiting_comment <card index.md>: `waiting.comment`, flow or block form; prints nothing (exit 1) when the card has no `waiting`
waiting_comment() {
  awk 'NR == 1 && /^---[ \t]*$/ { fm = 1; next } fm && /^---[ \t]*$/ { exit }
    fm && /^[^ \t]/ { inw = 0 }
    fm && /^waiting:/ { w = 1; inw = 1; v = $0 }
    fm && inw && /^[ \t]/ { v = v " " $0 }
    END { if (!w) exit 1
      if (match(v, /(^|[ {,])comment:[ \t]*["\x27]?[0-9A-Fa-f-]+/)) { c = substr(v, RSTART, RLENGTH); sub(/^.*comment:[ \t]*["\x27]?/, "", c); print c } }' "$1"
}
WAITING=0; WCOMMENT=$(waiting_comment "$CARD/index.md") && WAITING=1 || true
[ -n "$REPLY" ] || REPLY="$WCOMMENT"
if [ "$WAITING" = 1 ] && [ ! -e "$LINT_CLEARS" ]; then echo "settle-question.sh: waiting is set and $LINT_CLEARS is missing (install work beside discovery); nothing written" >&2; exit 1; fi
if [ "$WAITING" = 1 ] && [ ! -x "$LINT_CLEARS" ]; then echo "settle-question.sh: waiting is set and $LINT_CLEARS is not executable; nothing written" >&2; exit 1; fi

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); ORDER=$(next_order "$DEST")
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/discovery-settle.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT

awk -v o="order: $ORDER" -v m="modified: {at: $NOW, by: $BY}" '
  /^---[ \t]*$/ { n++ }
  n==1 && drop && /^[ \t]/ { next }          # its block lines, where the compact form opened it out
  { drop = 0 }
  n==1 && /^waiting:/ { drop = 1; next }
  n==1 && /^order:/ { print o; next }
  n==1 && /^modified:/ { print m; next }
  { print }' "$CARD/index.md" > "$STAGE/index.md"
if ! stamp_lines_ok "$STAGE/index.md" order modified; then echo "settle-question.sh: triple brace after restamp; aborting" >&2; exit 1; fi
{ printf '\n## Ruling\n\n'; tr -d '\r' < "$RULING"; } >> "$STAGE/index.md"

COID=""
if [ -n "$RECORD" ]; then
  COID=$(uuid); mkdir -p "$STAGE/comment"
  tr -d '\r' < "$RECORD" | comment_file "$STAGE/comment/index.md" "$NOW" "$BY" "$REPLY"
fi
if [ "$WAITING" = 1 ]; then   # the waiting-clear lint on the card as it will land: one lane, one card
  LC="$STAGE/lint/lane/$CID"; mkdir -p "$LC/comments"; cp "$STAGE/index.md" "$LC/index.md"
  for ci in "$CARD"/comments/*/index.md; do   # the lint reads only each comment's index.md: attachments stay out
    [ -f "$ci" ] || continue; cd_=$(basename "$(dirname "$ci")"); mkdir -p "$LC/comments/$cd_"; cp "$ci" "$LC/comments/$cd_/index.md"
  done
  [ -z "$COID" ] || cp -R "$STAGE/comment" "$LC/comments/$COID"
  LRC=0; LO=$("$LINT_CLEARS" "$STAGE/lint" 2>&1) || LRC=$?
  [ "$LRC" -lt 2 ] || { echo "settle-question.sh: lint-waiting-clears.sh failed (exit $LRC): $LO" >&2; exit 1; }
  case "$LO" in
    NO-QUOTE*) if [ -n "$RECORD" ]; then
                 NASK=$(printf '%s\n' "$LO" | awk '$1 == "NO-QUOTE" { print $3; exit }')
                 if [ -n "$NASK" ]; then echo "settle-question.sh: newest ask is $NASK and the record has no answer to it: the quote may be a bare > or sit inside a code fence, or --reply may name another ask; nothing written" >&2
                 else echo "settle-question.sh: the record does not answer the card's newest ask (--reply ${REPLY:-none}); nothing written" >&2; fi
               else echo "settle-question.sh: waiting is set and no owner comment answers the ask: pass --record with the owner's words (templates/ruling.md); nothing written" >&2; fi
               exit 1 ;;
    ""|QUOTED*) ;;
    *) echo "settle-question.sh: lint-waiting-clears.sh failed: $LO" >&2; exit 1 ;;
  esac
fi

CARD=$(find_card)
[ -n "$CARD" ] && [ -f "$CARD/index.md" ] || { echo "settle-question.sh: card $CID moved during settle; nothing written" >&2; exit 1; }
mv "$STAGE/index.md" "$CARD/index.md"
if [ -n "$COID" ]; then mkdir -p "$CARD/comments"; mv "$STAGE/comment" "$CARD/comments/$COID"; fi
if [ "$CARD" != "$DEST/$CID" ]; then mv "$CARD" "$DEST/$CID"; fi

printf 'settled %s -> %s (order %s)\n' "${CID:0:8}" "$LANE_TITLE" "$ORDER"
if [ -n "$COID" ]; then printf 'record comment %s\n' "$COID"; fi
printf 'lanework://%s/%s\n' "$(fm_value "$BOARD/index.md" id)" "$CID"
