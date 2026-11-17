---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:50:20Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:50:20Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and green: commit `26e763c` on `found-board-fixes`, smoke 83 passed.**

- **Evidence**: `env -u CLAUDE_MODEL bash tests/smoke.sh` ends `smoke: 83 passed`, exit 0. `tests/check-sizes.sh`: `48 rows, 0 wrong`.
- **Mutation**: restoring the raw `title "$TITLE"` in a scratch copy turns smoke red at the new case (`# one` / `two`).
