---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:46:57Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T10:46:57Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Fixer started on branch `recap-option` (worktree `.claude/worktrees/recap-option`, off `a09634d`).**

**Plan**: tests first (new lint-ask smoke cases), FAIL-BEFORE at a09634d, then edit `lint-ask.sh`, `ask.md`, `writing.md`, `responding.md`, `file-question.sh`, refresh README counts.
**Decided**: "has options" = any `- <Label>: <text>` list item in the body. The standing line is the exact text `- Recap: Explain this in plain terms first`, excluded from the word count.
