---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:54:59Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:54:59Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: fixer building on branch `script-stamps`, tests first.**

- **Decided**: `title_str` returns the escaped text without outer quotes, so the card templates' `"Q{{n}}: {{title}}"` prefix keeps working. `found-board.sh` board and lane titles go through it too.
- **Decided**: a `require_model` helper in `lib.sh` (flag, else `CLAUDE_MODEL`, else exit 2 with usage), called after argument parsing in the four scripts, before any write.
- **Plan**: two smoke cases, FAIL-BEFORE on the unchanged scripts, then the helper, the four scripts, the doc tables, and every existing smoke call passing `--model`.
