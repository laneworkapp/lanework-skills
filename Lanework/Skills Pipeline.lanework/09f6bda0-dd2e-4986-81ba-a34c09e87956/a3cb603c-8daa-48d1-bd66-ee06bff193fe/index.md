---
schema: 1
kind: card
title: "README sizes drift: generate or check the word counts"
order: 9216
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-06T22:56:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T02:41:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The README's per-file word counts are a hand-kept snapshot that drifts with every skill edit: today 9 of its 45 rows are wrong. Add a smoke case that recomputes them and fails on any mismatch.

- **Touches**: `tests/smoke.sh` (one new case), `README.md` § Sizes (refresh every count and the measured date once, so the case starts green).
- **Rule the case enforces**: for each skill, every row of its README table equals `wc -w` of that file under `skills/<name>/`; the `total` row equals the sum of the rows; the summary table's `files`, `SKILL.md words` and `words an agent reads` columns equal the per-skill table's row count, `SKILL.md` row and total. `SKILL.md` and every `references/*.md` must have a row. Templates are checked only when listed.
- **Failure output**: one line per bad row, `<skill>/<file>: README says N, wc -w says M`, then a non-zero exit.
- **Verify**: `bash -n tests/smoke.sh`, then `tests/smoke.sh` passes after the README refresh. In a scratch copy of the repo outside the board, change one row, then add an unlisted `references/*.md` to a skill, then change a total; smoke fails each time naming the file or total. Quote all three runs.
- **Done when**: smoke has a README-sizes case that passes on the refreshed README and fails, naming the row, on each of the three breakages above.
