#!/bin/bash
# found-discovery-board.sh: cold-start a discovery board.
# usage: found-discovery-board.sh "<path>/<Topic> Discovery.lanework" ["Title"] [--model m] [--name n]
# Writes index.md from templates/board.md and one lane per row of templates/lanes.md.
# Nothing else: the app installs CLAUDE.md, .schema and .gitignore on first open.
# Refuses a non-empty folder.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BOARD="${1:?usage: found-discovery-board.sh <path>/<Topic> Discovery.lanework [title] [--model m] [--name n]}"
shift
TITLE=""
if [ $# -gt 0 ] && [[ "$1" != --* ]]; then TITLE="$1"; shift; fi
MODEL="${CLAUDE_MODEL:-unknown}"; NAME="claude"
while [ $# -gt 0 ]; do
  case "$1" in
    --model) MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)  NAME="${2:?--name needs a value}"; shift 2 ;;
    *) echo "found-discovery-board.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
[ -n "$TITLE" ] || TITLE=$(basename "$BOARD" .lanework)
TOPIC="${TITLE% Discovery}"

if [ -d "$BOARD" ] && [ -n "$(ls -A "$BOARD" 2>/dev/null)" ]; then
  echo "found-discovery-board.sh: refusing, $BOARD exists and is not empty" >&2; exit 1
fi

case "$TITLE" in   # quote a title a bare YAML scalar would break on
  *": "*|"#"*|"["*|"{"*|"'"*|'"'*) TITLE_YAML="\"${TITLE//\"/\\\"}\"" ;;
  *) TITLE_YAML="$TITLE" ;;
esac

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL"); BOARD_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/discovery-found.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$BOARD"

render "$TEMPLATES/board.md" title "$TITLE" title_yaml "$TITLE_YAML" id "$BOARD_ID" \
  topic "$TOPIC" stamp "{at: $NOW, by: $BY}" > "$STAGE/index.md"
mv "$STAGE/index.md" "$BOARD/index.md"

# lanes.md rows: | order | title | collapsed | body |
awk -F'|' '/^\| *[0-9]/ { for (i = 2; i <= 5; i++) { gsub(/^ +| +$/, "", $i) } print $2 "\t" $3 "\t" $4 "\t" $5 }' \
  "$TEMPLATES/lanes.md" |
while IFS=$'\t' read -r ORDER LANE COLLAPSED LBODY; do
  LANE_ID=$(uuid); mkdir -p "$BOARD/$LANE_ID"
  {
    printf '%s\n' '---' 'schema: 1' 'kind: lane'
    printf 'title: %s\n' "$LANE"
    printf 'order: %s\n' "$ORDER"
    [ "$COLLAPSED" = yes ] && printf '%s\n' 'collapsed: true'
    printf 'created:  {at: %s, by: %s}\n' "$NOW" "$BY"
    printf 'modified: {at: %s, by: %s}\n' "$NOW" "$BY"
    printf '%s\n' '---' "$LBODY"
  } > "$STAGE/lane.md"
  mv "$STAGE/lane.md" "$BOARD/$LANE_ID/index.md"
done

printf 'founded %s\nboard id %s\n' "$BOARD" "$BOARD_ID"
