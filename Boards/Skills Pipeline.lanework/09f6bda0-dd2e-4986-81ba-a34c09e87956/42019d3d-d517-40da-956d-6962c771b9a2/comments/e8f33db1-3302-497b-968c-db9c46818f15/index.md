---
schema: 1
kind: comment
created:  {at: 2026-11-17T16:26:57Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Built on `move-receipts` at `33036c7`, pushed: smoke `203 passed`, check-sizes 0 wrong, check-refs 0 missing.**

- **FAIL-BEFORE**: the new case run against unchanged `events.md` fails with `events.md item 4 lacks moved: as a receipt, item 5 lacks moved.by, or it still says bare move with no comment`.
- **Changed**: `events.md` item 4 gains a receipt sub-bullet (a record, never replied to, whoever signed it); item 5 says "a move with no reply owed", `moved.by` names the mover, the receipt is read from the card's `comments/`. Item 6 untouched. README § Sizes: events 486, watch total 1,688.
- **Smoke last line**: `smoke: 203 passed`.
- **Unchecked**: a live watch reading a receipt (first app move on a receipts board).
