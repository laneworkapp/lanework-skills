#!/bin/bash
# found-board.sh: cold-start a board from an index template and a lanes table.
# usage: found-board.sh "<path>/<Name>.lanework" --index <template> --lanes <lanes.md> \
#          --model m [--title T] [--var key=value]... [--labels kind,...] [--name n]
# Index template gets {{title}}, {{title_yaml}}, {{id}}, {{stamp}} plus each --var.
# Slots: {{labels}} = ", labels: [rows]" (empty without --labels); {{label_entries}} = "row, row, " for a template that has labels of its own.
# --labels: catalog kinds (templates/label-kinds.md) spliced into config.labels; unknown or empty kind -> exit 2, nothing written.
#   The board's index.md is written in the compact form (lib.sh compact_fm): config opens into a block once it passes 120 characters.
#   Repeated --labels accumulate (a kind repeated across flags is written once); a kind twice in one list -> exit 2.
# Lanes table rows: | order | title | collapsed (yes) | icon (YAML flow mapping, or empty) | body |  (templates/*-lanes.md).
# Writes nothing else: the app installs CLAUDE.md, .schema and .gitignore on first open.
# Exit: 0 founded; 1 refused (non-empty folder, a folder that cannot be created, missing label-kinds.md, a brace in the stamp values), nothing written;
#   2 usage, nothing written (no argument, unknown argument, a flag with no value, an unreadable --index or --lanes, no model (--model, else CLAUDE_MODEL),
#   blank flattened --title, reserved --var, a template with {{label_entries}} but no --labels, --labels with no slot, bad label kind, a template that fails to render, e.g. a {{slot}} no --var fills).
# The folder is created only after the template renders, so a failed run leaves no folder; a lane that fails after that
# (its folder, its file, its stamp) is undone and exits 1: the folder removed only when this run created it, and from an
# empty folder that was there only what this run wrote.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

USAGE="found-board.sh <board> --index F --lanes F [--title T] [--var k=v]... --model m [--labels k,...] [--name n]"
[ $# -ge 1 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"
shift
INDEX=""; LANES=""; TITLE=""; LABELS=""; VARS=()
MODEL=""; NAME="claude"; HAVE_LABELS=""
KINDS="$(dirname "${BASH_SOURCE[0]}")/../templates/label-kinds.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --index) need_value "$@"; INDEX="$2"; shift 2 ;;
    --lanes) need_value "$@"; LANES="$2"; shift 2 ;;
    --title) need_value "$@"; TITLE="$2"; shift 2 ;;
    --var)   need_value "$@"; v="$2"; VARS+=("${v%%=*}" "${v#*=}"); shift 2 ;;
    --labels) [ $# -ge 2 ] || need_value "$@"; LABELS="$(merge_kinds "$LABELS" "$HAVE_LABELS" "$2")"; HAVE_LABELS=1; shift 2 ;;
    --model) need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)  [ $# -ge 2 ] || need_value "$@"; NAME="$2"; shift 2 ;;
    *) printf 'found-board.sh: unknown argument: %s\nusage: %s\n' "$1" "$USAGE" >&2; exit 2 ;;
  esac
done
require_model found-board.sh "$USAGE"
stamp_args_ok "$NAME" "$MODEL"
[ -r "$INDEX" ] || { echo "found-board.sh: --index must name a readable template" >&2; exit 2; }
[ -r "$LANES" ] || { echo "found-board.sh: --lanes must name a readable table" >&2; exit 2; }
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

render "$INDEX" title "$(flat_str "$TITLE")" title_yaml "\"$(title_str "$TITLE")\"" id "$BOARD_ID" \
  stamp "{at: $NOW, by: $BY}" labels "$LABELS_YAML" label_entries "$LABEL_ENTRIES" ${VARS[@]+"${VARS[@]}"} > "$STAGE/index.md" ||
  { echo "found-board.sh: the template did not render; nothing written" >&2; exit 2; }
compact_fm "$STAGE/index.md"
stamp_lines_ok "$STAGE/index.md" created modified || { echo "found-board.sh: a brace in the stamp (--model or --name); nothing written" >&2; exit 1; }
# CREATED: this run made the folder (mkdir, not -p, so a folder made meanwhile by another is never counted as ours).
# undo takes back what this run wrote: the whole folder only when CREATED, else its index.md and the lane folders it made
mkdir -p "$(dirname "$BOARD")"; CREATED=""
if mkdir "$BOARD" 2>/dev/null; then CREATED=1; else [ -d "$BOARD" ] || { echo "found-board.sh: cannot create $BOARD" >&2; exit 1; }; fi
undo() { local l; if [ -n "$CREATED" ]; then rm -rf "$BOARD"; else rm -f "$BOARD/index.md"; for l in $1; do rm -rf "${BOARD:?}/$l"; done; fi; }
mv "$STAGE/index.md" "$BOARD/index.md"

MADE=""   # the lane folders made so far (uuids), for undo; the loop runs in one pipeline subshell, so lane_fail undoes and exits there (pipefail + set -e carry the 1 out)
awk -F'|' '/^\| *[0-9]/ { for (i = 2; i <= 6; i++) { gsub(/^ +| +$/, "", $i) } print $2 "\037" $3 "\037" $4 "\037" $5 "\037" $6 }' "$LANES" |
# \037, not tab: tab is IFS whitespace, so an empty collapsed or icon cell would merge away and shift body.
while IFS=$'\037' read -r ORDER LANE COLLAPSED ICON LBODY; do
  lane_fail() { undo "$MADE"; echo "found-board.sh: $1; nothing written" >&2; exit 1; }
  LANE_ID=$(uuid) || lane_fail "no uuid for a lane"
  MADE="$MADE $LANE_ID"; mkdir -p "$BOARD/$LANE_ID" || lane_fail "cannot create a lane folder"
  {
    printf '%s\n' '---' 'schema: 1' 'kind: lane'
    printf 'title: %s\n' "\"$(title_str "$LANE")\""
    printf 'order: %s\n' "$ORDER"
    if [ -n "$ICON" ]; then printf 'icon: %s\n' "$ICON"; fi
    if [ "$COLLAPSED" = yes ]; then printf '%s\n' 'collapsed: true'; fi
    printf 'created:  {at: %s, by: %s}\n' "$NOW" "$BY"
    printf 'modified: {at: %s, by: %s}\n' "$NOW" "$BY"
    printf '%s\n' '---' "$LBODY"
  } > "$STAGE/lane.md" || lane_fail "cannot write a lane"
  stamp_lines_ok "$STAGE/lane.md" created modified || lane_fail "a brace in a lane stamp"
  mv "$STAGE/lane.md" "$BOARD/$LANE_ID/index.md" || lane_fail "cannot move a lane into the board"
done

sign_board "$BOARD"   # a no-op today: the folder was empty, so no seeded .gitignore yet
printf 'founded %s\nboard id %s\n' "$BOARD" "$BOARD_ID"
