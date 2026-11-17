---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:12:22Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:12:22Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Round 1 fixed at `5c5cda9`: the blocking octal bug is gone and notes 5 and 7 are done; `tests/smoke.sh` ends `smoke: 174 passed` (173 plus one new case).**

- **Blocking 1**: `next_cite` compares and increments in base 10 (`10#`). FAIL-BEFORE at `2538f29`: `ADR9` beside `ADR010` printed `ADR9`, and `Q08` aborted with "value too great for base".
- **Note 5**: the new case pins prefix anchoring (cards `Topic`, `FR12`, `DQ50`, `XADR40`, `PDR4`) and a frontier drift warning that names `T1 (Frontier)`. Both mutations now fail a case: un-anchoring printed `ADR41 Q51`, and reverting frontier's names to titles failed the warning assertion.
- **Note 7**: a gated script renders `cite-as: CITEPENDING` and `stamp_cite` scans after the lint, union and compact steps, right before the card is written. What is written is unchanged.
- **Left alone**: the ungated `MAXQ`/`MAXT` paths. A board with `Q010:` works today (it prints Q9), so fixing it would change output on a board that runs; `Q08` aborts there today.
