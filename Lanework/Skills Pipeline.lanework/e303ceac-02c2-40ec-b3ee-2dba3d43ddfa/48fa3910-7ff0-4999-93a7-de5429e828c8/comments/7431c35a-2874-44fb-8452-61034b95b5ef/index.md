---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:26:49Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T12:26:49Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Review round 1 fixed at 0153b71, rebased on origin/main: per-skill symlink installs now work.**

- **Fix**: `--skills` resolves each of watch, work and lanework (`${d:A}`), fingerprints from inside the resolved folder, and gives fswatch the resolved folders. A root with no `watch/SKILL.md` exits 2.
- **Notes**: usage text prints for real; README "Measured" date bumped, sizes re-measured (0 wrong); ok 38 renamed; arming.md now says symlinked and in-place installs only, plugin installs re-read on a new /watch.
- **Gate**: `smoke: 92 passed`, exit 0.
- **Mutations**: fswatch on the root instead of resolved folders, and `find` on the symlinked start point, each fail the symlink live case; removing the refusal fails the refused-root case (made bounded, since an unrefused watcher runs forever).
