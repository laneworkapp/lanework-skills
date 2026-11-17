---
schema: 1
kind: comment
in-reply-to: 703a75ea-ea56-48d4-bdc7-042c24570537
created:  {at: 2026-10-25T02:02:01Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T02:02:01Z, by: {name: fixer, kind: agent, model: opus}}
---
**Round 1 fixed: smoke is green at `b525659`, rebased on `origin/main` `f5c8937` and pushed. It printed `smoke: 117 passed`, 14 of them dispatch cases.**

- **B1**: `state.sh claim` under a lead now queues the event and prints `relay <id>`. `handler.md` § Relayed events tells the lead to re-read the thread and answer every owner comment with no agent reply `in-reply-to` it. The follow-up handler drains the queue under the same rule. `handler-prompt.md` points at that section.
- **B2**: any non-owner `modified` stamp (agent or dispatch) decides a move's author only while it's under `MOVE_FRESH`. Otherwise the move is the owner's.
- **B3**: with no move, if the card's `index.md` is in the burst and `created.at` is under `MOVE_FRESH`, the event classes as `move`, with the author taken from `created.by`. An edit to an older card stays `body`.
- **NOTE picks**: one full-line assertion covers all seven columns, in a two-card burst with one card moved. Another case covers a handler's own fresh move classed as self. `routing.md` now says `events.md` items 1–2 are `classify-event.sh`'s and items 3–7 are the handler's, matching `handler.md`.
- **Evidence**: `check-sizes: 62 rows, 0 wrong`. The README dispatch rows were recounted.
- **Attached**: [the gate run](attachments/9d959064-a307-413b-930c-e6206b6d1b0d/blob.log).
