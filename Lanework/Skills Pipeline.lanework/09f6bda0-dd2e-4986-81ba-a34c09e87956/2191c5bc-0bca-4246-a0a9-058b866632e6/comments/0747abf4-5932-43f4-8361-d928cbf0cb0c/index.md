---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:51:24Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:51:24Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and green: commit d08b6a4 on `label-kinds`, rebased onto main 3f68046. `tests/smoke.sh` prints `smoke: 72 passed` on the rebased head.**

- **Evidence**: the new block is cases 61 to 67. 61 golden identity without `--labels`; 62 all seven kinds, order, validates; 63 any subset on the plain template; 64 unknown, empty, blank (`a,,b`) kind exits 2, nothing written; 65 one flattened entry of each kind, no `DEPRECATED`; 66 `SUGGESTED` equals the two catalog rows; 67 heal without the catalog file exits non-zero naming it. Existing heal cases 1 to 60 unchanged and green.
- **Changed**: `templates/label-kinds.md` (new), `templates/index.md` and `pipeline-index.md` (slot), `found-board.sh`, `heal-board.py`, `references/founding.md`, `references/board-kinds.md`, `SKILL.md`, `README.md` (feature line, Sizes rows for lanework), `tests/smoke.sh`, `tests/fixtures/` (two goldens).
- **Noted**: duplicate kinds in `--labels` also exit 2. `discovery/templates/board.md` keeps its own config and is not touched. `heal-board.py --global` stays until the guide drops `default-labels`.
