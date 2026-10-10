#!/bin/bash
# found-board.sh: cold-start a board from an index template and a lanes table.
# usage: found-board.sh "<path>/<Name>.lanework" --index <template> --lanes <lanes.md> \
#          --model m [--title T] [--var key=value]... [--labels kind,...] [--name n]
# Index template gets {{title}}, {{title_yaml}}, {{id}}, {{stamp}} plus each --var.
# Slots: {{labels}} = ", labels: [rows]" (empty without --labels); {{label_entries}} = "row, row, " for a template that has labels of its own.
# --labels: catalog kinds (templates/label-kinds.md) spliced into config.labels; unknown or empty kind -> exit 2, nothing written.
#   Repeated --labels accumulate (a kind repeated across flags is written once); a kind twice in one list -> exit 2.
# Lanes table rows: | order | title | collapsed (yes) | icon (YAML flow mapping, or empty) | body |  (templates/*-lanes.md).
# Writes nothing else: the app installs CLAUDE.md, .schema and .gitignore on first open.
# Refuses a non-empty folder.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BOARD="${1:?usage: found-board.sh <board> --index F --lanes F [--title T] [--var k=v]... --model m [--labels k,...] [--name n]}"
shift
INDEX=""; LANES=""; TITLE=""; LABELS=""; VARS=()
MODEL=""; NAME="claude"; HAVE_LABELS=""
KINDS="$(dirname "${BASH_SOURCE[0]}")/../templates/label-kinds.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --index) INDEX="${2:?--index needs a file}"; shift 2 ;;
    --lanes) LANES="${2:?--lanes needs a file}"; shift 2 ;;
    --title) TITLE="${2:?--title needs a value}"; shift 2 ;;
    --var)   v="${2:?--var needs key=value}"; VARS+=("${v%%=*}" "${v#*=}"); shift 2 ;;
    --labels) LABELS="$(merge_kinds "$LABELS" "$HAVE_LABELS" "${2?--labels needs a kind list}")"; HAVE_LABELS=1; shift 2 ;;
    --model) MODEL="${2:?--model needs a value}"; shift 2 ;;
    --name)  NAME="${2:?--name needs a value}"; shift 2 ;;
    *) echo "found-board.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
require_model found-board.sh "found-board.sh <board> --index F --lanes F --model m [--title T] [--var k=v]... [--labels k,...] [--name n]"
[ -r "$INDEX" ] || { echo "found-board.sh: --index must name a readable template" >&2; exit 1; }
[ -r "$LANES" ] || { echo "found-board.sh: --lanes must name a readable table" >&2; exit 1; }
[ -n "$TITLE" ] || TITLE=$(basename "$BOARD" .lanework)
[ -n "$(flat_str "$TITLE" | tr -d '[:space:]')" ] || { echo "found-board.sh: --title is blank once its line breaks are flattened" >&2; exit 2; }
# the slot names and the built-in keys are the script's: a --var can't overwrite them
set -- ${VARS[@]+"${VARS[@]}"}
while [ $# -gt 0 ]; do
  case "$1" in labels|label_entries|title|title_yaml|id|stamp) echo "found-board.sh: --var $1 is reserved" >&2; exit 2 ;; esac
  shift 2
done
HAS_LABELS_SLOT=""; grep -q '{{labels}}\|{{label_entries}}' "$INDEX" && HAS_LABELS_SLOT=1
if [ -z "$HAVE_LABELS" ] && grep -q '{{label_entries}}' "$INDEX"; then
  echo "found-board.sh: $INDEX needs --labels (it holds {{label_entries}})" >&2; exit 2
fi
LABELS_YAML=""; LABEL_ENTRIES=""
if [ -n "$HAVE_LABELS" ]; then
  [ -r "$KINDS" ] || { echo "found-board.sh: $KINDS is missing" >&2; exit 1; }
  ROWS=""; SEEN=","; REST="$LABELS,"   # an empty name anywhere (empty list, "a,,b", trailing comma) is an unknown kind
  while [ -n "$REST" ]; do
    k="${REST%%,*}"; REST="${REST#*,}"
    row=$(awk -F'|' -v k="$k" '/^\|/ { n=$2; e=$3; gsub(/^ +| +$/, "", n); gsub(/^ +| +$/, "", e); if (n == k && e ~ /^\{/) { print e; exit } }' "$KINDS")
    [ -n "$row" ] || { echo "found-board.sh: unknown label kind '$k' (known: $(awk -F'|' '/^\|/ { n=$2; e=$3; gsub(/ /, "", n); if (e ~ /^ *\{/) { printf "%s%s", s, n; s="," } }' "$KINDS"))" >&2; exit 2; }
    case "$SEEN" in *",$k,"*) echo "found-board.sh: label kind '$k' named twice" >&2; exit 2 ;; esac
    SEEN="$SEEN$k,"; ROWS="${ROWS:+$ROWS, }$row"
  done
  LABELS_YAML=", labels: [$ROWS]"; LABEL_ENTRIES="$ROWS, "
  [ -n "$HAS_LABELS_SLOT" ] || { echo "found-board.sh: --labels given but $INDEX has no {{labels}} or {{label_entries}} slot" >&2; exit 2; }
fi
if [ -d "$BOARD" ] && [ -n "$(ls -A "$BOARD" 2>/dev/null)" ]; then
  echo "found-board.sh: refusing, $BOARD exists and is not empty" >&2; exit 1
fi

NOW=$(now_utc); BY=$(by_of "$NAME" "$MODEL"); BOARD_ID=$(uuid)
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/lanework-found.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$BOARD"

render "$INDEX" title "$(flat_str "$TITLE")" title_yaml "\"$(title_str "$TITLE")\"" id "$BOARD_ID" \
  stamp "{at: $NOW, by: $BY}" labels "$LABELS_YAML" label_entries "$LABEL_ENTRIES" ${VARS[@]+"${VARS[@]}"} > "$STAGE/index.md"
mv "$STAGE/index.md" "$BOARD/index.md"

awk -F'|' '/^\| *[0-9]/ { for (i = 2; i <= 6; i++) { gsub(/^ +| +$/, "", $i) } print $2 "\037" $3 "\037" $4 "\037" $5 "\037" $6 }' "$LANES" |
# \037, not tab: tab is IFS whitespace, so an empty collapsed or icon cell would merge away and shift body.
while IFS=$'\037' read -r ORDER LANE COLLAPSED ICON LBODY; do
  LANE_ID=$(uuid); mkdir -p "$BOARD/$LANE_ID"
  {
    printf '%s\n' '---' 'schema: 1' 'kind: lane'
    printf 'title: %s\n' "\"$(title_str "$LANE")\""
    printf 'order: %s\n' "$ORDER"
    if [ -n "$ICON" ]; then printf 'icon: %s\n' "$ICON"; fi
    if [ "$COLLAPSED" = yes ]; then printf '%s\n' 'collapsed: true'; fi
    printf 'created:  {at: %s, by: %s}\n' "$NOW" "$BY"
    printf 'modified: {at: %s, by: %s}\n' "$NOW" "$BY"
    printf '%s\n' '---' "$LBODY"
  } > "$STAGE/lane.md"
  mv "$STAGE/lane.md" "$BOARD/$LANE_ID/index.md"
done

printf 'founded %s\nboard id %s\n' "$BOARD" "$BOARD_ID"
