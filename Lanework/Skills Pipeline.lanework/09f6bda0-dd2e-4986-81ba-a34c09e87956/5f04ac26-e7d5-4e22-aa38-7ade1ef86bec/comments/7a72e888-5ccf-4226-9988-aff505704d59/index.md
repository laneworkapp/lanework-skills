---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:50:10Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:50:10Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START and FAIL-BEFORE: the new smoke case fails on unchanged source with the heading split over two lines.**

- **Branch**: `found-board-fixes`, worktree `.claude/worktrees/found-board-fixes`, at merge-base `bca7ced`. Bundled with [d97756aa](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d97756aa-1002-4ea5-bd9d-f634a6fecd8b).
- **FAIL-BEFORE**: `env -u CLAUDE_MODEL bash tests/smoke.sh` at `bca7ced` plus only the new case. Output ends with the founded index, frontmatter `title: "one two"` and body `# one` then `two`. Raw run: `fail-before-1.txt` in the fixer scratchpad.
- **Decided**: `flat_str` turns CRLF into one space, so `title_str` now gives one space for CRLF where it gave two. The case covers LF, CR and CRLF through `found-board.sh` and `found-discovery-board.sh`.
