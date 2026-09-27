#!/bin/bash
# found-board.sh: cold-start a board from an index template and a lanes table.
# usage: found-board.sh "<path>/<Name>.lanework" --index <template> --lanes <lanes.md> \
#          [--title T] [--var key=value]... [--model m] [--name n]
# Index template gets {{title}}, {{title_yaml}}, {{id}}, {{stamp}} plus each --var.
# Lanes table rows: | order | title | collapsed (yes) | body |  (templates/*-lanes.md).
# Writes nothing else: the app installs CLAUDE.md, .schema and .gitignore on first open.
# Refuses a non-empty folder.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BOARD="${1:?usage: found-board.sh <board> --index F --lanes F [--title T] [--var k=v]... [--model m] [--name n]}"
shift
INDEX=""; LANES=""; TITLE=""; VARS=()
MODEL="${CLAUDE_MODEL:-unknown}"; NAME="claude"
while [ $# -gt 0 ]; do
  case "$1" in
    --index) INDEX="${2:?--index needs a file}"; shift 2 ;;
    --lanes) LANES="${2:?--lanes needs a file}"; shift 2 ;;
    --title) TITLE="${2:?--title needs a value}"; shift 2 ;;
    --var)   v="${2:?--var needs key=value}"; VARS+=("${v%%=*}" "${v#*=}"); shift 2 ;;
    --model) MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)  NAME="${2:?--name needs a value}"; shift 2 ;;
    *) echo "found-board.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
[ -r "$INDEX" ] || { echo "found-board.sh: --index must name a readable template" >&2; exit 1; }
[ -r "$LANES" ] || { echo "found-board.sh: --lanes must name a readable table" >&2; exit 1; }
[ -n "$TITLE" ] || TITLE=$(basename "$BOARD" .lanework)
if [ -d "$BOARD" ] && [ -n "$(ls -A "$BOARD" 2>/dev/null)" ]; then
  echo "found-board.sh: refusing, $BOARD exists and is not empty" >&2; exit 1
fi

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL"); BOARD_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/lanework-found.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$BOARD"

render "$INDEX" title "$TITLE" title_yaml "$(yaml_str "$TITLE")" id "$BOARD_ID" \
  stamp "{at: $NOW, by: $BY}" ${VARS[@]+"${VARS[@]}"} > "$STAGE/index.md"
mv "$STAGE/index.md" "$BOARD/index.md"

awk -F'|' '/^\| *[0-9]/ { for (i = 2; i <= 5; i++) { gsub(/^ +| +$/, "", $i) } print $2 "\t" $3 "\t" $4 "\t" $5 }' "$LANES" |
while IFS=$'\t' read -r ORDER LANE COLLAPSED LBODY; do
  LANE_ID=$(uuid); mkdir -p "$BOARD/$LANE_ID"
  {
    printf '%s\n' '---' 'schema: 1' 'kind: lane'
    printf 'title: %s\n' "$(yaml_str "$LANE")"
    printf 'order: %s\n' "$ORDER"
    if [ "$COLLAPSED" = yes ]; then printf '%s\n' 'collapsed: true'; fi
    printf 'created:  {at: %s, by: %s}\n' "$NOW" "$BY"
    printf 'modified: {at: %s, by: %s}\n' "$NOW" "$BY"
    printf '%s\n' '---' "$LBODY"
  } > "$STAGE/lane.md"
  mv "$STAGE/lane.md" "$BOARD/$LANE_ID/index.md"
done

printf 'founded %s\nboard id %s\n' "$BOARD" "$BOARD_ID"
