#!/bin/bash
# check-refs.sh: every `skill/dir/file` or `dir/file` path cited in skills/ must exist.
# `dir/file` resolves inside the citing skill; `skill/dir/file` from skills/.
set -uo pipefail
cd "$(dirname "$0")/../skills"
n=0; bad=0
while IFS=: read -r f ref; do
  ref=${ref//\`/}; s=$(echo "$f" | cut -d/ -f2); n=$((n+1))
  case "$ref" in
    references/*|templates/*|scripts/*) target="$s/$ref" ;;
    *) target="$ref" ;;
  esac
  if [ ! -e "$target" ]; then echo "MISSING $target (cited in $f)"; bad=$((bad+1)); fi
done < <(grep -roE '`([a-z-]+/)?(references|templates|scripts)/[A-Za-z0-9_.-]+`' --include='*.md' --include='*.sh' .)
echo "check-refs: $n references, $bad missing"
[ "$n" -gt 0 ] && [ "$bad" -eq 0 ]
