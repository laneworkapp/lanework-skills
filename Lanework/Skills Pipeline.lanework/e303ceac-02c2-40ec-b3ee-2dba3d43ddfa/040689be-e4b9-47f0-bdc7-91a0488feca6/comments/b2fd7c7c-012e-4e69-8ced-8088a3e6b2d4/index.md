---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:51:12Z, by: {name: shaper, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:51:12Z, by: {name: shaper, kind: agent, model: sonnet}}
in-reply-to: 4b9a4c09-4670-42e1-ad70-7d2ce128c85e
---
**Confirmed done: the bump rule, the changelog and a bumped first release all exist, so it moves to Done.**

- **Rule in one place**: `CLAUDE.md:31-35` § Releasing. Bump = patch for fixes and wording, minor for new behavior or a guide-version move, major for a renamed or removed skill. `README.md` § Versioning points at it and says the version lives in `plugin.json` alone.
- **Changelog**: `CHANGELOG.md` exists in the `app-changelog` format, monthly grouping newest-first, one `Version X.Y.Z:` line per release (0.1.0, 0.2.0, 0.2.1, 0.2.2).
- **First release under it**: `plugin.json` moved off 0.1.0 and now reads 0.2.2. Tags v0.1.0, v0.2.0, v0.2.1 and v0.2.2 exist, each with a "Release vX.Y.Z" commit (e75ca03, 26b987d, bb70060) and a changelog commit before it.
- **Smoke-style check, shipped differently**: `scripts/release.sh` refuses a release unless `CHANGELOG.md` has a `Version X.Y.Z: ` entry and the version is not below `plugin.json`'s; it bumps `plugin.json` itself, tags, moves `stable` and writes the GitHub release notes from the new changelog entries.
- **Rejected as written**: the card's "smoke check that the top entry matches `plugin.json`". The release gate checks the same thing at the moment it matters, and main's `plugin.json` is allowed to trail while work is in progress.
