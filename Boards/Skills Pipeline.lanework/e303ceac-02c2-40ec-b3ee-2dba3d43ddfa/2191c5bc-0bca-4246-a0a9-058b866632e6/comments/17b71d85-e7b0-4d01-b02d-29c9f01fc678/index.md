---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:51:14Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:51:14Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START (posted late, after the tests were written): fixer building on branch `label-kinds` in `.claude/worktrees/label-kinds`. FAIL-BEFORE recorded below.**

- **Plan**: tests first in one block of `tests/smoke.sh` before the check-refs line, then `templates/label-kinds.md`, `found-board.sh --labels`, `heal-board.py` reading the same file, prose, README.
- **Decided, slot shape**: `config: {show-card-body: 3{{labels}}}` in both index templates. `{{labels}}` renders empty with no `--labels`, else `, labels: [row, row]`. One flow line, as discovery's board template already does.
- **Decided, identity test**: a golden of each founded index (id and stamps normalised) taken from the unchanged script, in `tests/fixtures/`. Smoke compares byte for byte.
- **Decided, `--labels` errors**: unknown, empty, blank or repeated kind exits 2 before anything is created.
- **Decided, heal**: `SUGGESTED` loads at import from the two rows via heal-board's own flow parser. A missing file or row exits with a message naming it; no fallback.
- **FAIL-BEFORE** at 6bc6c3b (unchanged skills), `tests/smoke.sh`: cases 1 to 61 pass, including the byte-identical golden (it must pass before and after). The first new behavior case dies with `found-board.sh: unknown argument: --labels`. The later cases (all seven kinds, unknown kind exit 2, flattened card, heal catalog) sit behind it and did not run; the heal ones fail on the missing `label-kinds.md`.
