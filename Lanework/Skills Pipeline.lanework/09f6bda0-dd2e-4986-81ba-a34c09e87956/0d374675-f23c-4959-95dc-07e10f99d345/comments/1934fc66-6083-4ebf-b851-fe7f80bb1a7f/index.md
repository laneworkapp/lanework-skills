---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:22:24Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:22:24Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Round 2b built on `lane-actors`, rebased onto current main: the full `tests/smoke.sh` passes, 64 of 64.**

- **Decided**: the holding-lane rule is stated once, in the sheet's Agent lanes line and the `board-kinds.md` intro. The pipeline bodies use the owner's wording verbatim; design-loop, datapoint and discovery bodies are cut to one sentence on the lane and one on who acts.
- **Decided**: `heal-descriptors.py` composes the Agent lanes line from the new `Names: rule` shape, keeping only lanes the board has.
- **Evidence**: smoke case 44 now asserts the sheet line carries the rule and that no Ideas, Issues or Tasks body has agents act unasked. README sizes table regenerated; no conflict markers.
- **Not touched**: the board (the lead rewrites the sheet and the Issues and Tasks bodies).
