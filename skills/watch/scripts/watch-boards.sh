#!/bin/zsh
# Watch board watcher: fswatch-triggered snapshot diff over one or more boards.
#
# Usage: watch-boards.sh [--skills <skills-root>] <state-file> <board-path>...
#
# Per burst, per board: `CHANGED <Board>.lanework/<path>` for each changed file, or
# `BULK: <n> files changed in <Board>.lanework` when more than 20 changed.
# Boards are named by folder, so two boards sharing a folder name are refused:
# watch those in separate Monitors.
#
# --skills <root> (the folder holding watch/, work/ and lanework/, each possibly a symlink;
# a root with no watch/SKILL.md is refused, exit 2):
# fingerprint of the rule files a watch reads (watch/**/*.md, work/SKILL.md,
# work/references/*.md, lanework/references/{authority,board-kinds}.md) kept in
# <state-file>.skills; the root joins fswatch. A different fingerprint, on a burst or
# at start against the stored one, emits one `SKILLS CHANGED`. No stored value yet =
# store it, emit nothing. Without --skills nothing changes.
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
USAGE="usage: watch-boards.sh [--skills <skills-root>] <state-file> <board-path>..."
SKILLS=
if [[ ${1:-} == --skills ]]; then
  SKILLS=${2:-}; [[ -n $SKILLS ]] || { echo "$USAGE" >&2; exit 2 }
  shift 2
  [[ -f $SKILLS/watch/SKILL.md ]] || { echo "watch-boards.sh: --skills wants the folder that holds watch/, work/ and lanework/ (no watch/SKILL.md in $SKILLS)" >&2; exit 2 }
  SKILLS=${SKILLS:A}
fi
STATE=${1:-}; [[ -n $STATE ]] || { echo "$USAGE" >&2; exit 2 }
shift
(( $# )) || { echo "$USAGE" >&2; exit 2 }

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

# each skill folder may be a symlink (per-skill installs): resolve it, find from inside it,
# and give fswatch the resolved folder, since edits land in the link target
SKDIRS=()
for n in watch work lanework; do d=$SKILLS/$n; [[ -d $d ]] && SKDIRS+=(${d:A}); done
skills_fp() {
  local n
  for n in watch work lanework; do
    ( cd "$SKILLS/$n" 2>/dev/null || exit 0
      case $n in
        watch) find . -name '*.md' ;;
        work) ls ./SKILL.md ./references/*.md ;;
        lanework) ls ./references/authority.md ./references/board-kinds.md ;;
      esac 2>/dev/null | sort -u | xargs shasum -a 256 2>/dev/null | sed "s#  \./#  $n/#" )
  done | shasum -a 256 | cut -d' ' -f1
}
# compare with the stored fingerprint, store the new one; emit once when it differs
skills_check() {
  [[ -n $SKILLS ]] || return 0
  local new old=; new=$(skills_fp)
  [[ -f $STATE.skills ]] && old=$(<"$STATE.skills")
  [[ $new == "$old" ]] && return 0
  printf '%s\n' "$new" > "$STATE.skills"
  [[ -z $old ]] || echo "SKILLS CHANGED"
}

snap > "$STATE"
skills_check
fswatch -r -o -l 0.5 "${BOARDS[@]}" "${SKDIRS[@]}" | while IFS= read -r _; do
  skills_check
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
