#!/bin/zsh
# Pitwall board watcher: fswatch-triggered snapshot diff over one or more boards.
#
# Usage: watch-boards.sh <state-file> <board-path>...
#
# Per burst, per board: `CHANGED <Board>.lanework/<path>` for each changed file, or
# `BULK: <n> files changed in <Board>.lanework` when more than 20 changed.
# Boards are named by folder, so two boards sharing a folder name are refused:
# watch those in separate Monitors.
#
# fswatch is ONLY the trigger; the emitted paths come from a find-snapshot diff.
# Never filter fswatch's own event paths: the app posts a comment by renaming
# comments/.draft/ -> comments/<uuid>/ and moves cards between lanes the same
# way, so file-level FSEvents carry only the renamed DIRECTORY paths, never the
# unchanged index.md inside. A path filter on the raw events silently drops
# exactly the owner comments and card moves the watch exists for. The snapshot
# diff sees every path that appeared, vanished, or changed, whatever the app
# did on disk.
#
# -o collapses each event burst to one counter line (count discarded, it only
# fires the diff); -l 0.5 batches a burst so a lane move lands as one diff.
set -u
LC_ALL=C
STATE=${1:?usage: watch-boards.sh <state-file> <board-path>...}
shift
(( $# )) || { echo "usage: watch-boards.sh <state-file> <board-path>..." >&2; exit 2 }

BOARDS=()
for b in "$@"; do
  b=${b%/}; b=${b:A}
  [[ -f $b/index.md ]] || { echo "watch-boards.sh: not a board: $b" >&2; exit 2 }
  BOARDS+=("$b")
done
names=(${BOARDS:t})
uniq=(${(u)names})
(( ${#uniq} == ${#names} )) || { echo "watch-boards.sh: two boards share a folder name; watch them separately" >&2; exit 2 }

snap() { find "${BOARDS[@]}" -name '*.md' -not -path '*/.trash/*' -not -path '*/comments/.draft/*' -exec stat -f '%m %z %N' {} + 2>/dev/null | sort; }

snap > "$STATE"
fswatch -r -o -l 0.5 "${BOARDS[@]}" | while IFS= read -r _; do
  snap > "$STATE.new"
  changed=$(comm -3 "$STATE" "$STATE.new" | cut -d' ' -f3- | sort -u)
  mv "$STATE.new" "$STATE"
  [[ -n $changed ]] || continue
  for b in "${BOARDS[@]}"; do
    mine=$(printf '%s\n' "$changed" | awk -v p="$b/" -v h="${b:h}/" 'index($0, p) == 1 { print substr($0, length(h) + 1) }')
    [[ -n $mine ]] || continue
    n=$(printf '%s\n' "$mine" | wc -l | tr -d ' ')
    if (( n > 20 )); then
      echo "BULK: $n files changed in ${b:t}"
    else
      printf '%s\n' "$mine" | sed 's/^/CHANGED /'
    fi
  done
done
