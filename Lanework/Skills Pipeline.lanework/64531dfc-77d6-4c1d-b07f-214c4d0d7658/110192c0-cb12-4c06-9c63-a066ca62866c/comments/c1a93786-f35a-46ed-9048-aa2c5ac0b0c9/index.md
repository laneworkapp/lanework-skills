---
schema: 1
kind: comment
created:  {at: 2026-11-14T22:15:14Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: 9f8ac0e0-ed85-416d-a5cd-f880ba22e7d7
---
**`scripts/release.sh X.Y.Z` runs seven checks, then publishes: a tag, the `stable` branch moved to it, and a GitHub release. It already refuses on the guide version today, because one of its checks is smoke.**

**Checks, in order** (any failure stops it, nothing changed):
1. On `main`.
2. No tracked changes outside `Lanework/`.
3. `main` equals `origin/main`.
4. The tag `vX.Y.Z` is unused.
5. The version is not below the one in `.claude-plugin/plugin.json`.
6. `CHANGELOG.md` has an entry starting `Version X.Y.Z: `.
7. `tests/smoke.sh` passes.

**Then it prints the release notes**: the `CHANGELOG.md` lines added since the previous tag. With `--dry-run` it stops here.

**Then it publishes**:
1. Sets `version` in `plugin.json` and commits it as "Release vX.Y.Z", if it moved.
2. Makes the annotated tag.
3. Pushes `main` and the tag.
4. Moves `stable` to the tagged commit. This is what plugin users get on their next update.
5. Creates the GitHub release with those notes.

- **Nothing here reads the guide version directly.** Check 7 does: smoke fails when this board's working-tree guide is newer than the stamp.
- **So today**: on this machine the working-tree guide reads v117 and the stamp v114. Smoke is red, and `release.sh` would refuse any release, 0.8.0 included, until [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) lands or this card does.
- **Under each option**: A, smoke goes green with a note, and the release prints a warning before the notes. B, smoke goes green, and a new check 8 refuses while the committed guide is ahead of the stamp. C, the smoke check and the stamp go, and the release never mentions the guide.
- **Source**: `scripts/release.sh`, 49 lines, read in full. Not run.
