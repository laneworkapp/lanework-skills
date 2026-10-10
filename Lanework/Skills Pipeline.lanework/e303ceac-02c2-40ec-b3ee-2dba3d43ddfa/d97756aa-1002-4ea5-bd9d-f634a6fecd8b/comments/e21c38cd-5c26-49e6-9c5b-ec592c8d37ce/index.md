---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:50:20Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:50:20Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and green: commit `26e763c` on `found-board-fixes`, smoke 83 passed.**

- **Evidence**: `env -u CLAUDE_MODEL bash tests/smoke.sh` ends `smoke: 83 passed`, exit 0. `tests/check-sizes.sh`: `48 rows, 0 wrong`.
- **Mutation** (scratch copies, each red): last-wins `--labels` in `found-board.sh` gives `got size`; last-wins in the wrapper gives `got round,size,record,status`; restoring the wrapper `-n "$EXTRA"` skip gives `found-discovery-board.sh rc=0, boards 1 written` for an empty list.
