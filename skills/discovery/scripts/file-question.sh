#!/bin/bash
# file-question.sh: file the next question card into Asked.
# usage: file-question.sh <board> "<title, no Q-number>" --round N --body F \
#          --model m [--ask F] [--depends <link>]... [--why T] [--name n] [--session s]
# Mints Q<n> from the highest across all lanes. Card frontmatter from templates/question-card.md,
# body from --body, `## Depends on` appended from --depends. Two comments, 1s apart: founding
# record (--why, no handle), then the ask (`waiting.comment` points at it).
# No --ask: built from --body (first paragraph, Options bullets, first sentence of Recommended,
# matching "If no answer"), then linted with work's lint-ask.sh (warns, never aborts).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"
LINT_SCRIPT="$LIB_DIR/../../work/scripts/lint-ask.sh"

BOARD="${1:?usage: file-question.sh <board> <title> --round N --body F [...]}"
TITLE="${2:?usage: file-question.sh <board> <title> --round N --body F [...]}"
shift 2
ROUND=""; BODY_FILE=""; ASK_FILE=""; WHY="**On the frontier now.**"
MODEL=""; NAME="claude"; SESSION=""; DEPENDS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --round)   ROUND="${2:?--round needs a value}"; shift 2 ;;
    --body)    BODY_FILE="${2:?--body needs a file}"; shift 2 ;;
    --ask)     ASK_FILE="${2:?--ask needs a file}"; shift 2 ;;
    --depends) DEPENDS+=("${2:?--depends needs a link}"); shift 2 ;;
    --why)     WHY="${2:?--why needs text}"; shift 2 ;;
    --model)   MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)    NAME="${2:?--name needs a value}"; shift 2 ;;
    --session) SESSION="${2:?--session needs a value}"; shift 2 ;;
    *) echo "file-question.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
require_model file-question.sh "file-question.sh <board> <title> --round N --body F --model m [...]"
[ -n "$ROUND" ] || { echo "file-question.sh: --round is required" >&2; exit 1; }
[ -n "$BODY_FILE" ] && [ -r "$BODY_FILE" ] || { echo "file-question.sh: --body must name a readable file" >&2; exit 1; }
[ -z "$ASK_FILE" ] || [ -r "$ASK_FILE" ] || { echo "file-question.sh: --ask must name a readable file" >&2; exit 1; }
[ -f "$BOARD/index.md" ] || { echo "file-question.sh: not a board: $BOARD" >&2; exit 1; }

ASKED=$(lane_by_title "$BOARD" Asked) || { echo "file-question.sh: no Asked lane on $BOARD" >&2; exit 1; }
BOARD_ID=$(fm_value "$BOARD/index.md" id)
HANDLE=$(owner_handle "$BOARD" || true); HANDLE="${HANDLE:-human}"

# ---- next global Q number, every lane, dot-folders excluded ----
MAXQ=0
while IFS= read -r f; do
  t=$(strip_quotes "$(fm_value "$f" title)")
  if [[ "$t" =~ ^Q([0-9]+): ]] && [ "${BASH_REMATCH[1]}" -gt "$MAXQ" ]; then MAXQ="${BASH_REMATCH[1]}"; fi
done < <(find "$BOARD" -mindepth 1 -maxdepth 1 -type d -name '.*' -prune -o -mindepth 3 -maxdepth 3 -type f -name index.md -print)
NEXTQ=$((MAXQ + 1))

section_of() {  # section_of <file> <heading>: lines under "## <heading>"
  awk -v h="## $2" '$0 == h { f=1; next } f && /^## / { exit } f' "$1"
}
joined() { awk 'NF' | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ +//; s/ +$//'; }

build_ask() {
  local para opts rec def
  para=$(awk '/^## / { exit } 1' "$BODY_FILE" | joined)
  opts=$(section_of "$BODY_FILE" Options | grep -E '^-[[:space:]]' || true)
  rec=$(section_of "$BODY_FILE" Recommended | joined)
  [[ "$rec" == *.* ]] && rec="${rec%%.*}."
  if [[ "$rec" =~ ^([A-Z])[.,] ]]; then def="${BASH_REMATCH[1]} stands when the round closes."
  else def="the recommendation stands when the round closes."; fi
  printf '@%s %s\n\n' "$HANDLE" "$para"
  [ -n "$opts" ] && printf 'Options:\n%s\n\n' "$opts"
  printf 'Recommended: %s\nIf no answer: %s\nContext: body.\n' "$rec" "$def"
}

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION")
CARD_ID=$(uuid); FOUND_ID=$(uuid); ASK_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/discovery-ask.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
C="$STAGE/$CARD_ID"; mkdir -p "$C/comments/$FOUND_ID" "$C/comments/$ASK_ID"

frontmatter_of "$TEMPLATES/question-card.md" > "$STAGE/fm.md"
{
  render "$STAGE/fm.md" n "$NEXTQ" title "$(title_str "$TITLE")" order "$(next_order "$ASKED")" \
    round "$ROUND" handle "$HANDLE" since "$NOW" ask_id "$ASK_ID" stamp "{at: $NOW, by: $BY}"
  cat "$BODY_FILE"
  if [ "${#DEPENDS[@]}" -gt 0 ]; then
    printf '\n## Depends on\n\n'; printf -- '- %s\n' "${DEPENDS[@]}"
  fi
} > "$C/index.md"

printf '%s\n' "$WHY" | comment_file "$C/comments/$FOUND_ID/index.md" "$(now_utc 1)" "$BY"
{ if [ -n "$ASK_FILE" ]; then cat "$ASK_FILE"; else build_ask; fi; } |
  comment_file "$C/comments/$ASK_ID/index.md" "$(now_utc 2)" "$BY"

if [ -x "$LINT_SCRIPT" ]; then
  LINT_OUT=$("$LINT_SCRIPT" "$C/comments/$ASK_ID/index.md" "$BOARD" 2>&1) || true
  [ -z "$LINT_OUT" ] || printf 'file-question.sh: lint-ask warning:\n%s\n' "$LINT_OUT" >&2
else
  echo "file-question.sh: warning: no lint-ask.sh at $LINT_SCRIPT" >&2
fi

mv "$C" "$ASKED/$CARD_ID"
printf 'lanework://%s/%s\nshort id %s\nask comment %s\n' "$BOARD_ID" "$CARD_ID" "${CARD_ID:0:8}" "$ASK_ID"
