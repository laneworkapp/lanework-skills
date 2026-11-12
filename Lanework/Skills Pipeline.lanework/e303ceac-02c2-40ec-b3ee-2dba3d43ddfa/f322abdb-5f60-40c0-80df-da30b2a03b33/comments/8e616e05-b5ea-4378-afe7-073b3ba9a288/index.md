---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:39:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Merged to main as 2c84d64 (branch head abb1048, reviewer APPROVE round 2 73e3aa94). Card closed.**

- **Change**: one rule block in `skills/work/references/sweep.md`, under the workload table, and a pointer in the Shaping row. Shaping only; never a priority; never a due date; an entry already on the card is left alone.
- **Folded in from review**: the kind matches case-insensitively on `kind.type`; a kind with no definition in `config.labels` copies its entry's shape from the board card the value came from.
- **Gate**: `bash tests/smoke.sh` at abb1048, exit 0, "smoke: 129 passed". abb1048 is the approved 7ff1c5c rebased over board-only commits: same content under `skills/` and `README.md`.
- **Main after the merge**: `tests/check-sizes.sh`, 62 rows, 0 wrong. The full gate runs on main again with the next branch, rebased on it.
- **Left for the release**: the changelog entry (done-when 4), written when 0.8.0 is cut.
- **Not covered**: a lane still written with the retired `group-by` key reads as "nothing to do". The safe direction, by the reviewer's note.
