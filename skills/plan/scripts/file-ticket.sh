#!/bin/bash
# file-ticket.sh: file the next ticket card into Frontier, or Blocked while a dependency is open.
# usage: file-ticket.sh <board> "<title, no T-number>" --type grilling|research|prototype|task \
#          --body F --model m [--depends <link>]... [--why T] [--name n] [--session s]
# On a board whose app draws `cite-as` (lib.sh `cite_enabled`) mints `cite-as: T<n>` (lanework/references/writes.md) and files a bare title; on any other
# board the title is `T<n>: <title>` from the highest across all lanes, as before. Frontmatter from templates/ticket-card.md (flattened
# `Ticket` label), body from --body, `## Depends on` appended from --depends: each a
# lanework://<this board's id>/<card-uuid> link to a ticket already on the board, written as
# `- [<citation, else title>](<link>)`. A dependency in Out of scope is refused (rule the dependent out too,
# or drop it). Lands at the bottom of Frontier when every dependency is in Resolved (or none),
# else the bottom of Blocked. The destination lane's card-defaults labels are unioned in. One founding comment (--why, default "**Charted.**"). No waiting.
# Prints the card's link, its short id and the lane it landed in.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"

BOARD="${1:?usage: file-ticket.sh <board> <title> --type t --body F --model m [...]}"
TITLE="${2:?usage: file-ticket.sh <board> <title> --type t --body F --model m [...]}"
shift 2
TYPE=""; BODY_FILE=""; WHY="**Charted.**"
MODEL=""; NAME="claude"; SESSION=""; DEPENDS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --type)    TYPE="${2:?--type needs a value}"; shift 2 ;;
    --body)    BODY_FILE="${2:?--body needs a file}"; shift 2 ;;
    --depends) DEPENDS+=("${2:?--depends needs a link}"); shift 2 ;;
    --why)     WHY="${2:?--why needs text}"; shift 2 ;;
    --model)   MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)    NAME="${2:?--name needs a value}"; shift 2 ;;
    --session) SESSION="${2:?--session needs a value}"; shift 2 ;;
    *) echo "file-ticket.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
require_model file-ticket.sh "file-ticket.sh <board> <title> --type grilling|research|prototype|task --body F --model m [...]"
case "$TYPE" in
  grilling)  LABEL=Grilling;  RANK=1; GLYPH=bubble.left.and.bubble.right ;;
  research)  LABEL=Research;  RANK=2; GLYPH=magnifyingglass ;;
  prototype) LABEL=Prototype; RANK=3; GLYPH=hammer ;;
  task)      LABEL=Task;      RANK=4; GLYPH=checklist ;;
  *) echo "file-ticket.sh: --type is grilling, research, prototype or task" >&2; exit 1 ;;
esac
[ -n "$BODY_FILE" ] && [ -r "$BODY_FILE" ] || { echo "file-ticket.sh: --body must name a readable file" >&2; exit 1; }
[ -f "$BOARD/index.md" ] || { echo "file-ticket.sh: not a board: $BOARD" >&2; exit 1; }
FRONTIER=$(lane_by_title "$BOARD" Frontier) || { echo "file-ticket.sh: no Frontier lane on $BOARD" >&2; exit 1; }
BLOCKED=$(lane_by_title "$BOARD" Blocked) || { echo "file-ticket.sh: no Blocked lane on $BOARD" >&2; exit 1; }
BOARD_ID=$(fm_value "$BOARD/index.md" id)

# ---- dependencies: this board's links to existing tickets; any not in Resolved -> Blocked ----
DEP_LINES=(); OPEN=0
for link in ${DEPENDS[@]+"${DEPENDS[@]}"}; do
  [[ "$link" =~ ^lanework://$BOARD_ID/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$ ]] \
    || { echo "file-ticket.sh: --depends wants lanework://$BOARD_ID/<card-uuid>, got: $link" >&2; exit 1; }
  dcard=$(ls -d "$BOARD"/*/"${BASH_REMATCH[1]}" 2>/dev/null | head -1 || true)
  [ -n "$dcard" ] && [ -f "$dcard/index.md" ] || { echo "file-ticket.sh: no card ${BASH_REMATCH[1]} on the board (file dependencies first)" >&2; exit 1; }
  dlane=$(strip_quotes "$(fm_value "$(dirname "$dcard")/index.md" title)")
  dtitle=$(card_ref "$dcard/index.md")
  case "$dlane" in
    "Out of scope") echo "file-ticket.sh: $dtitle is Out of scope: rule this ticket out too, or drop the dependency" >&2; exit 1 ;;
    Resolved) ;;
    *) OPEN=1 ;;
  esac
  DEP_LINES+=("- [$dtitle]($link)")
done
if [ "$OPEN" -eq 1 ]; then DEST="$BLOCKED"; DEST_TITLE=Blocked; else DEST="$FRONTIER"; DEST_TITLE=Frontier; fi

# ---- an older board: next global T number from the title prefixes, every lane, dot-folders excluded ----
if ! cite_enabled "$BOARD"; then
  MAXT=0
  while IFS= read -r f; do
    t=$(strip_quotes "$(fm_value "$f" title)")
    if [[ "$t" =~ ^T([0-9]+): ]] && [ "${BASH_REMATCH[1]}" -gt "$MAXT" ]; then MAXT="${BASH_REMATCH[1]}"; fi
  done < <(find "$BOARD" -mindepth 1 -maxdepth 1 -type d -name '.*' -prune -o -mindepth 3 -maxdepth 3 -type f -name index.md -print)
fi

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL" "$SESSION")
CARD_ID=$(uuid); FOUND_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/plan-ticket.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
C="$STAGE/$CARD_ID"; mkdir -p "$C/comments/$FOUND_ID"

if cite_enabled "$BOARD"; then   # the citation is scanned later (stamp_cite), just before the card is written
  CITE=CITEPENDING; CARD_TITLE=$(title_str "$TITLE"); frontmatter_of "$TEMPLATES/ticket-card.md" > "$STAGE/fm.md"
else
  CITE="T$((MAXT + 1))"; CARD_TITLE="$CITE: $(title_str "$TITLE")"; frontmatter_of "$TEMPLATES/ticket-card.md" | grep -v '^cite-as:' > "$STAGE/fm.md"
fi
render "$STAGE/fm.md" cite "$CITE" title "$CARD_TITLE" order "$(next_order "$DEST")" \
  type "$LABEL" rank "$RANK" glyph "$GLYPH" stamp "{at: $NOW, by: $BY}" > "$STAGE/fm.out"
if grep -q '}}}' "$STAGE/fm.out"; then echo "file-ticket.sh: triple brace in the frontmatter; aborting" >&2; exit 1; fi
union_lane_defaults "$DEST" "$BOARD" "$STAGE/fm.out"
compact_fm "$STAGE/fm.out"
if cite_enabled "$BOARD"; then CITE=$(stamp_cite "$STAGE/fm.out" "$BOARD" T); fi   # scanned here, after the slow steps
{
  cat "$STAGE/fm.out"
  cat "$BODY_FILE"
  if [ "${#DEP_LINES[@]}" -gt 0 ]; then
    printf '\n## Depends on\n\n'; printf '%s\n' "${DEP_LINES[@]}"
  fi
} > "$C/index.md"
printf '%s\n' "$WHY" | comment_file "$C/comments/$FOUND_ID/index.md" "$(now_utc 1)" "$BY"

DEST=$(lane_by_title "$BOARD" "$DEST_TITLE")
mv "$C" "$DEST/$CARD_ID"
printf 'lanework://%s/%s\nshort id %s\n%s -> %s\n' "$BOARD_ID" "$CARD_ID" "${CARD_ID:0:8}" "$CITE" "$DEST_TITLE"
