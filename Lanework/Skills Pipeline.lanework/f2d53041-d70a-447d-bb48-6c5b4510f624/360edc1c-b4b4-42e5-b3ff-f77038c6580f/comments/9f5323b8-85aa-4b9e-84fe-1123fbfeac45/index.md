---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:51:17Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:51:17Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**START: fixer builds the card as two commits, the minimum first and `post-comment.sh` second so it can be dropped at review.**

**Plan**: smoke cases first, FAIL-BEFORE on the merge-base `ed4cc29`. Commit 1: clock rule in `writes.md`, clause in `farmed-prompt.md`, `lint-stamps.sh`, `SKILL.md` pointer, smoke cases, README § Sizes. Commit 2: `post-comment.sh`, pointers in `writing.md` and `ask.md`, smoke cases, README § Sizes.
**Branch**: `clock-stamps-360edc1c`, worktree `.claude/worktrees/clock-stamps-360edc1c`. No `CHANGELOG.md` or `plugin.json` change.
