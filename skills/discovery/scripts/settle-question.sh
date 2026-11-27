#!/bin/bash
# settle-question.sh: record a ruling on a question card and move it.
# usage: settle-question.sh <board> <card-uuid> --ruling F [--to settled|parked] \
#          [--record F [--reply <ask-uuid>]] --model m [--name n] [--session s]
# Appends `## Ruling` + the --ruling text (templates/ruling.md), drops `waiting`, restamps,
# posts --record (a `>` quote line and a `**Given**` line, else exit 2) as a comment (in reply to --reply, default the card's
# `waiting.comment`, or its newest ask when `waiting` is gone), moves the card to the bottom of Settled or Parked. --ruling and --record are written with LF line ends.
# `waiting` set, or cleared with a `Recap:` click on the card (and the lint present): the staged card and its comments are run through work/scripts/lint-waiting-clears.sh first; a NO-QUOTE
# (no owner comment answers the newest ask, and no record in reply to it) = exit 1, nothing written. So a click that left `waiting` cleared still needs --record or a real answer.
# A `Recap:` click (a human comment whose first body line starts `Recap:`, a UTF-8 BOM ignored; any size) is not an owner answer: it stays out of the lint's copy.
# Exit 2, nothing written: usage (a missing positional, flag or flag value, an unknown flag, an unreadable --ruling or --record, a --record without its quote and Given lines, a bad --to, no model (--model, else CLAUDE_MODEL)).
# Exit 1, nothing written: no such lane or card, a NO-QUOTE, the lint missing or failing, the card moved during the settle, a brace in the stamp values.
# Staged outside the board; the card path is re-resolved just before landing.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
LINT_CLEARS="$LIB_DIR/../../work/scripts/lint-waiting-clears.sh"

USAGE='settle-question.sh <board> <card-uuid> --ruling F [--to settled|parked] [--record F [--reply <ask-uuid>]] --model m [--name n] [--session s]'
[ $# -ge 2 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; CID="$2"
shift 2
TO="settled"; REPLY=""; RULING=""; RECORD=""
MODEL=""; NAME="claude"; SESSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --to)      need_value "$@"; TO="$2"; shift 2 ;;
    --reply)   need_value "$@"; REPLY="$2"; shift 2 ;;
    --ruling)  need_value "$@"; RULING="$2"; shift 2 ;;
    --record)  need_value "$@"; RECORD="$2"; shift 2 ;;
    --model)   need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)    [ $# -ge 2 ] || need_value "$@"; NAME="$2"; shift 2 ;;
    --session) need_value "$@"; SESSION="$2"; shift 2 ;;
    *) echo "settle-question.sh: unknown argument: $1" >&2; echo "usage: $USAGE" >&2; exit 2 ;;
  esac
done
require_model settle-question.sh "settle-question.sh <board> <card-uuid> --ruling F --model m [...]"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
[ -r "${RULING:-}" ] || { echo "settle-question.sh: --ruling must name a readable file" >&2; exit 2; }
[ -z "$RECORD" ] || [ -r "$RECORD" ] || { echo "settle-question.sh: --record must name a readable file" >&2; exit 2; }
if [ -n "$RECORD" ]; then
  grep -q '^>' "$RECORD" && grep -q '\*\*Given\*\*' "$RECORD" || { echo "settle-question.sh: --record needs a '>' quote line and a '**Given**: <where>, <date>' line (templates/ruling.md)" >&2; exit 2; }
fi
case "$TO" in settled) LANE_TITLE=Settled ;; parked) LANE_TITLE=Parked ;; *) echo "settle-question.sh: --to is settled or parked" >&2; exit 2 ;; esac
DEST=$(lane_by_title "$BOARD" "$LANE_TITLE") || { echo "settle-question.sh: no lane titled $LANE_TITLE" >&2; exit 1; }

# is_recap_click <comment index.md>: exit 0 when the first non-blank body line starts `Recap:` and `created.by` is not kind: agent (no `by` = human)
# CRs and a UTF-8 BOM at any line start are dropped first; awk reads to the end (an early exit would break the pipe under pipefail on a large comment)
is_recap_click() {
  LC_ALL=C perl -pe 's/\r//g; s/^\xEF\xBB\xBF//' < "$1" | awk '
    NR == 1 && /^---[ \t]*$/ { fm = 1; next }
    fm && /^---[ \t]*$/ { fm = 0; body = 1; next }
    fm && /^[^ \t]/ { inc = ($0 ~ /^created:/) }
    fm && inc && /kind:[ \t]*["\x27]?agent/ { agent = 1 }
    body && !done && /[^ \t]/ { click = ($0 ~ /^[ \t]*Recap:/); done = 1 }
    END { exit (done && click && !agent) ? 0 : 1 }'
}

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
# newest_ask: uuid of the card's newest agent comment whose first body line starts `@` (the lint's ask), for a card whose `waiting` is gone
newest_ask() {
  for ci in "$CARD"/comments/*/index.md; do
    [ -f "$ci" ] || continue
    perl -pe 's/\r//g; s/^\xEF\xBB\xBF//' < "$ci" | awk -v id="$(basename "$(dirname "$ci")")" '
      NR == 1 && /^---[ \t]*$/ { fm = 1; next }
      fm && /^---[ \t]*$/ { fm = 0; body = 1; next }
      fm && /^[^ \t]/ { inc = ($0 ~ /^created:/) }
      fm && inc && /kind:[ \t]*["\x27]?agent/ { agent = 1 }
      fm && inc && match($0, /at:[ \t]*["\x27]?[0-9T:Z.-]+/) { at = substr($0, RSTART, RLENGTH); sub(/^at:[ \t]*["\x27]?/, "", at) }
      body && !done && /[^ \t]/ { done = 1; ask = ($0 ~ /^@/) }
      END { if (agent && ask) print at, id }'
  done | sort | tail -1 | cut -d' ' -f2
}
if [ -z "$REPLY" ] && [ "$WAITING" = 0 ]; then REPLY=$(newest_ask || true); fi   # waiting cleared (by the app after a click): --record answers the newest ask
LINT=$WAITING   # waiting cleared by the app after a click: the lint still runs, when it is there (a card with no waiting and no click settles as before)
if [ "$LINT" = 0 ] && [ -x "$LINT_CLEARS" ]; then
  for ci in "$CARD"/comments/*/index.md; do [ -f "$ci" ] && is_recap_click "$ci" && { LINT=1; break; }; done
fi
if [ "$WAITING" = 1 ] && [ ! -e "$LINT_CLEARS" ]; then echo "settle-question.sh: waiting is set and $LINT_CLEARS is missing (install work beside discovery); nothing written" >&2; exit 1; fi
if [ "$WAITING" = 1 ] && [ ! -x "$LINT_CLEARS" ]; then echo "settle-question.sh: waiting is set and $LINT_CLEARS is not executable; nothing written" >&2; exit 1; fi

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION"); ORDER=$(next_order "$DEST")
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/discovery-settle.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT

LW_O="order: $ORDER" LW_M="modified: {at: $NOW, by: $BY}" awk '   # ENVIRON, not -v: awk -v interprets backslash escapes in a stamp value
  BEGIN { o = ENVIRON["LW_O"]; m = ENVIRON["LW_M"] }
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
if [ "$LINT" = 1 ]; then   # the waiting-clear lint on the card as it will land: one lane, one card
  LC="$STAGE/lint/lane/$CID"; mkdir -p "$LC/comments"; cp "$STAGE/index.md" "$LC/index.md"
  for ci in "$CARD"/comments/*/index.md; do   # the lint reads only each comment's index.md: attachments stay out
    [ -f "$ci" ] || continue; ! is_recap_click "$ci" || continue; cd_=$(basename "$(dirname "$ci")"); mkdir -p "$LC/comments/$cd_"; cp "$ci" "$LC/comments/$cd_/index.md"
  done
  [ -z "$COID" ] || cp -R "$STAGE/comment" "$LC/comments/$COID"
  LRC=0; LO=$("$LINT_CLEARS" "$STAGE/lint" 2>&1) || LRC=$?
  [ "$LRC" -lt 2 ] || { echo "settle-question.sh: lint-waiting-clears.sh failed (exit $LRC): $LO" >&2; exit 1; }
  case "$LO" in
    NO-QUOTE*) if [ -n "$RECORD" ]; then
                 NASK=$(printf '%s\n' "$LO" | awk '$1 == "NO-QUOTE" { print $3; exit }')
                 if [ -n "$NASK" ]; then echo "settle-question.sh: newest ask is $NASK and the record has no answer to it: the quote may be a bare > or sit inside a code fence, or --reply may name another ask; nothing written" >&2
                 else echo "settle-question.sh: the record does not answer the card's newest ask (--reply ${REPLY:-none}); nothing written" >&2; fi
               else echo "settle-question.sh: the card's newest ask has no owner answer (a Recap: click is none): pass --record with the owner's words (templates/ruling.md); nothing written" >&2; fi
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
sign_board "$BOARD"

printf 'settled %s -> %s (order %s)\n' "${CID:0:8}" "$LANE_TITLE" "$ORDER"
if [ -n "$COID" ]; then printf 'record comment %s\n' "$COID"; fi
printf 'lanework://%s/%s\n' "$(fm_value "$BOARD/index.md" id)" "$CID"
