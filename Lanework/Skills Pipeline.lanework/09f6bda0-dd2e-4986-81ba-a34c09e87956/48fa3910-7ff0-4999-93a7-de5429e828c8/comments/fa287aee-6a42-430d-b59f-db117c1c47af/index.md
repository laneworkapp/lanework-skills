---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:44:08Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:44:08Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: fixer (sonnet) building on branch `watch-reread`, worktree `.claude/worktrees/watch-reread`, base bca7ced.**

- **Decided, first run**: no stored `<state>.skills` = store silently, emit nothing. A fresh arm just read the rules.
- **Decided, fingerprint**: sha256 over `shasum` of each rule file (relative path, sorted): `watch/**/*.md`, `work/SKILL.md`, `work/references/*.md`, `lanework/references/{authority,board-kinds}.md`. A removed or added file changes it.
- **Decided, tests**: scratch skills copy and scratch board under the smoke temp dir; bounded polling, with a board probe file proving fswatch is live before each assertion.
