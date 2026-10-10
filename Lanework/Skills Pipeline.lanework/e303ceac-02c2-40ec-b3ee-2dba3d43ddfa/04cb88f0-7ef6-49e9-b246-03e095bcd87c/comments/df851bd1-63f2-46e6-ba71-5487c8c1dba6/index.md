---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:45:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:45:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shaped and moved to Proposed. The ruled design stands, and the gaps were in what it touches and when it can land.**

**Added to Touches**: `scripts/release.sh`. It ignores uncommitted changes only under `Pitlane/`, so after the move every unsaved board write would block a release.
**Decided**: the rename offer covers `~/Pitlane/` too, with a plain `mv` since it is not a repo. This machine has one.
**Order**: after the skill rename and the current campaign. Both edit the same files, and open worktrees still carry `Pitlane/` paths.
**Evidence**: `git grep Pitlane` outside the board finds `finding.md`, `sweep.md`, `arming.md`, the pitlane `SKILL.md`, `README.md`, `CLAUDE.md`, `tests/smoke.sh:7`, `scripts/release.sh:4,18`, and history in `CHANGELOG.md`, which stays.
