---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:34:47Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T10:34:47Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**FAIL-BEFORE recorded: the new smoke assertion fails against the unchanged catalog with the card's observable.**

- **Command**: the assertion block alone (extracted from `tests/smoke.sh`), run at `f9ba99c` source (origin/main; `label-kinds.md` unchanged).
- **Failure line**: `AssertionError: {'glyph': 'square.grid.2x2'}` then `the type kind does not carry icon: {glyph: cube}`, exit 1.
- **Raw output**: attached (fail-before.txt).
