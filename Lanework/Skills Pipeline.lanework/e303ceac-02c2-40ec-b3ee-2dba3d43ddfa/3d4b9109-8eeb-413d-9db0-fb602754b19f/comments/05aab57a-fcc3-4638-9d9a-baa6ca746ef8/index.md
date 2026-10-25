---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:26:17Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T11:26:17Z, by: {name: fixer, kind: agent, model: opus}}
---
**Round 1 changes are done: compacted stamps quote YAML words, the merge writes whole floats as integers, and `writes.md` keeps one of several `single` lane defaults. Smoke is green at `386ceb1`, rebased onto `origin/main` `cb44f12` and pushed.**

- **BLOCKING fixed**: `heal-board.py`'s `emit_scalar` now matches the board heal v2. A stamp's plain word that is in `YAML_WORDS` (`true`, `false`, `yes`, `no`, `on`, `off`, `null`, `y`, `n`, `~`, any case) stays quoted. In ok 21/22, the "Stamp over lines" seed now carries `model: "on", session: "Yes"`.
- **FAIL-BEFORE, YAML words**: the new smoke with `e58deea`'s `heal-board.py` fails `compact-collection: wrong rewrite`. The rewritten stamp reads `created:  {at: 2026-10-01T00:00:00Z, by: {name: claude, kind: agent, model: on, session: Yes}}`. Log: [smoke-yamlword-before.log](attachments/ba79e4d1-b21f-402d-840b-134cec4147d2/blob.log).
- **Float (lead's pick a)**: `lanework-merge.py` `dump` writes a whole-number float as an integer. Side A's L1 `y` label carries `rank: 2.0`, and merge-case asserts `{text: "y", rank: 2, kind:`. FAIL-BEFORE with `e58deea`'s driver: `labels: a whole-number float not written as the heal writes it (2, not 2.0)`, with the merged line reading `rank: 2.0`. Log: [merge-float-before.log](attachments/71f1052d-4f0f-423c-b191-217b6f324a76/blob.log).
- **writes.md (lead's pick b)**: several lane defaults of one `single` kind keep one (the lowest `rank`, else the first). README § Sizes: writes.md 974, lanework total 4,150.
- **Not done**: the card-defaults union in the filing scripts. The lead filed it as a follow-up.
- **Gate**: `bash tests/smoke.sh` at `386ceb1`, exit 0, `smoke: 121 passed`. `ok 22` parity holds with the YAML-word seed, `ok 118` and `ok 120` read v101, and `check-sizes: 62 rows, 0 wrong`. Log: [smoke-r2.log](attachments/ba0d1812-3623-4867-b045-ddcfd3261501/blob.log).
