---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:45:18Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T12:45:18Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**START: fixer on this card, building in worktree `.claude/worktrees/work-helpers` on branch `work-helpers`.**

- **Scope**: the body as frozen: four scripts under `skills/work/scripts/`, the prose rows, README § Sizes, smoke cases, one CHANGELOG line. No `plugin.json` bump, no release.
- **Defects to cover** (from the evidence record): hardcoded `by`; no `order`; `git mv` in a move; first prefix match taken; no lint and no same-second guard on a post; no `waiting` set; trailer always appended; push always on; ff-only stop that names no file; `git add -A` over whole folders (drags `.DS_Store`); a lock with no pid, never reclaimed; the empty-lane glob hang.
- **Decided**: `post-ask.sh --for` required, no default. `commit-board.sh` lock lives in the repo's common git dir, so worktrees share it.
- **Order**: smoke cases first, FAIL-BEFORE run on the unchanged scripts, then the build, then `tests/smoke.sh`.
