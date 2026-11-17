---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:11:21Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**START: building in the worktree on branch `retire-dispatch`, tests first.**

- **Scope**: the body is the spec. Move `arm-pass.sh` to watch, add § Arming pass and the compaction bullet to `arming.md`, delete `skills/dispatch/`, fix manifest, README, smoke, check-sizes.
- **Order**: new smoke cases first, FAIL-BEFORE recorded against the unchanged tree, then the build.
- **Not mine**: the board body's skill list and closing the two Active dispatch cards (the lead, at landing). No version bump, no release.
