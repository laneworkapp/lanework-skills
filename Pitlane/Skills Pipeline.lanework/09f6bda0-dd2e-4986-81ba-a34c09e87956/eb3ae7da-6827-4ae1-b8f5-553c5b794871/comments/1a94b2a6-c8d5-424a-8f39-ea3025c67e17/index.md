---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:10:10Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T23:10:10Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: fixer picked up the card in worktree `.claude/worktrees/rename-skills`, branch `rename-skills`.**

**Plan**: smoke check first (no pitlane or pitwall folder or plugin entry), run it red on the unchanged tree, then `git mv` both folders and sweep citations, README, plugin.json, CLAUDE.md, tests. Board part (instruction sheet and open-card `Skill` labels) after the code commit.
**Kept**: the `Pitlane/` folder convention and CHANGELOG history. `~/.claude/skills` untouched.
