---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:50:08Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:50:08Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**FAIL-BEFORE: the new smoke case fails on the unchanged script at bca7ced, on the card's observable.**

- **Run**: `env -u CLAUDE_MODEL bash tests/smoke.sh` at bca7ced + the new case only. Cases 1 to 61 pass, then: `drop-stale left a bare bullet or touched a neighbour: .../Heal Stale own.lanework`, diff `14d13 < -` (the bare bullet).
- **Mutation check** (old one-regex step, `count=1`, run on the five fixtures' text outside the repo): wrong on own bullet (bare `-`), fence (edited), quote (edited) and mixed (first hit wins, in the fence); right on inline. The new step is right on all five.
- **Decided**: a fifth fixture (fence and quote hits first, a real bullet hit later) covers "first hit wins even when the real one comes later".
- **Decided**: board-kinds key reworded to "agents move cards in, and out only once the ruling is in the body (discovery Asked)"; sweep row 27 follows the `gate` key and Ideas stays in Holding only. Read against guide v84: no conflict.
