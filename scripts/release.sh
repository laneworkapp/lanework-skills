#!/bin/bash
# release.sh: cut a release of the lanework plugin from main.
# usage: scripts/release.sh <version> [--dry-run]
# Checks: on main, in sync with origin, no tracked changes outside the board folder (Lanework/, or legacy Pitlane/), tag unused,
# version not below plugin.json's, CHANGELOG.md carries a "Version <version>:" entry, smoke green.
# Then: version bump in plugin.json (a release commit, if it moved), annotated tag v<version>,
# push main + tag, fast-forward the stable branch to the tag, GitHub release whose notes are the
# CHANGELOG entries added since the previous tag. --dry-run checks, prints the notes, changes nothing.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
V="${1:?usage: release.sh <version> [--dry-run]}"; DRY="${2:-}"
die() { echo "release.sh: $*" >&2; exit 1; }
[[ "$V" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "version must be X.Y.Z, got $V"
[ -z "$DRY" ] || [ "$DRY" = --dry-run ] || die "unknown argument: $DRY"
TAG="v$V"; M=.claude-plugin/plugin.json

[ "$(git symbolic-ref --short HEAD)" = main ] || die "not on main"
[ -z "$(git status --porcelain --untracked-files=no -- . ':!Lanework' ':!Pitlane')" ] || die "tracked changes outside Lanework/ and Pitlane/; commit or drop them first"
git fetch -q origin main
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || die "main and origin/main differ; pull or push first"
! git rev-parse -q --verify "refs/tags/$TAG" >/dev/null || die "$TAG already exists"
CUR=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$M")
python3 - "$CUR" "$V" <<'EOF' || die "$V is below plugin.json's $CUR"
import sys; a, b = (tuple(map(int, v.split("."))) for v in sys.argv[1:]); sys.exit(b < a)
EOF
grep -q "^Version $V: " CHANGELOG.md || die "CHANGELOG.md has no entry starting \"Version $V: \""
tests/smoke.sh >/dev/null || die "smoke failed; run tests/smoke.sh to see it"

PREV=$(git describe --tags --abbrev=0 --match 'v*' 2>/dev/null || true)
NOTES=$(mktemp "${TMPDIR:-/tmp}/lanework-notes.XXXXXX"); trap 'rm -f "$NOTES"' EXIT
if [ -n "$PREV" ]; then git diff -U0 "$PREV" HEAD -- CHANGELOG.md | sed -n 's/^+\([^+*].*\)$/\1/p'
else grep -v -e '^\*\*' -e '^$' CHANGELOG.md; fi | awk '{print; print ""}' > "$NOTES"
[ -s "$NOTES" ] || die "no new CHANGELOG entries since ${PREV:-the start}"

echo "release $TAG (manifest $CUR, previous tag ${PREV:-none}), notes:"; echo; cat "$NOTES"
[ -z "$DRY" ] || { echo "dry run: nothing changed"; exit 0; }

if [ "$CUR" != "$V" ]; then
  python3 - "$M" "$V" <<'EOF'
import re, sys; p, v = sys.argv[1:]; s = open(p).read()
open(p, "w").write(re.sub(r'("version"\s*:\s*")[^"]*"', r'\g<1>' + v + '"', s, count=1))
EOF
  git commit -q --only -m "Release $TAG" -- "$M"
fi
git tag -a "$TAG" -m "Release $TAG"
git push -q origin main "$TAG"
git push -q origin "$TAG^{commit}:refs/heads/stable"
gh release create "$TAG" --title "$TAG" --notes-file "$NOTES"
echo "released $TAG; stable -> $(git rev-parse --short "$TAG^{commit}")"
