---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:20:49Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T23:20:49Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: building in worktree `boards-folder`, two commits, skills and repo code first, then the `git mv`.**

- **Branch**: `boards-folder`, worktree `.claude/worktrees/boards-folder`, based on main after the work/watch rename.
- **Plan**: commit 1 = finding.md (three names, globs, offer, `~/`), founding.md, arming.md, sweep.md, README, CLAUDE.md, smoke.sh, release.sh, plus a smoke check that fails first. Commit 2 = `git mv Pitlane Lanework` and path fixes.
- **Decided**: the offer lives in finding.md only; arming.md, sweep.md and founding.md point at it. `work/SKILL.md` names no folder today, so it is untouched unless a grep says otherwise.
- **Not touched**: the live board on main, `~/Pitlane`.
