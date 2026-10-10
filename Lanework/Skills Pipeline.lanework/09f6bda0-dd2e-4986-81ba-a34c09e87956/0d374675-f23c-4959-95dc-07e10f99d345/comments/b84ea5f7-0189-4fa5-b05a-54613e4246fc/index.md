---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:35:01Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:35:01Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Round 3 built on `lane-actors`, rebased onto main: the full `tests/smoke.sh` passes, 65 of 65.**

- **Decided, B1**: `none` marks Done, discovery Facts, Settled, Decisions and Parked, design-loop Dead ends and datapoint Filed: never a work order. Arming and responding take work orders from `agent` rows only. Smoke greps that none of those rows is `agent`.
- **Decided, B2**: `drop-stale` removes "A chore the owner files in Tasks has passed both."; `replace-flow` swaps the released Flow bullet for the current one, or turns a customised Flow's released Tasks clause into "and Tasks as a side entrance". Both are listed in the dry run and in the digest. The released text is in `OLD_SHEET`, from the git history of `pipeline-index.md`.
- **Decided, notes**: the key is agent, gate, holding, none, stated once. The sheet line says "move a card out or start its work only when asked". Watch says "no work order: report". Datapoint Ideas says "promote one only when asked". sweep.md cites board-kinds.
- **Evidence**: new smoke case: a pre-ruling sheet loses the sentence, gets the current Flow, validates, and a second run gives 0 changes.
