---
schema: 1
kind: comment
created:  {at: 2026-11-20T21:11:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START, 2026-11-20: moved by the owner from Issues straight into Approved; taken into Active ahead of the other approved cards, since 0.9.0 waits on it.**

- **Session**: lanework-skills Pitwall. **Branch**: `commit-board-push-reject`, worktree `.claude/worktrees/commit-board-push-reject`, from `origin/main` at `2a600e3`.
- **No proposal yet**: this card skipped Shaping. The fixer first reproduces the loss in a throwaway repo and writes the change and its done-when; the lead puts them in this body before the fix is judged against them.
- **Scope**: the staged-work loss after a rejected push, and after five failed pushes. The two smaller items in the body (the header comment on SIGKILL, `lint-ask.sh` exiting 1 on no arguments) ride along only if they stay one-line changes.
- **Plan after that**: a reviewer checks the branch against the written done-when; the lead merges on approval and runs smoke on main before pushing.
- **Tests**: throwaway repos and boards only, never this one.
