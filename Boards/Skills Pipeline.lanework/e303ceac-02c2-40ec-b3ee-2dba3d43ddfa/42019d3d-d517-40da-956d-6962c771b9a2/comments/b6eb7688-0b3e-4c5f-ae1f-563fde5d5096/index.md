---
schema: 1
kind: comment
created:  {at: 2026-11-17T16:47:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: watch reads a move receipt as the record of a move. On main, not released.**

- **Merge**: `ff5ee47` on main, from branch `move-receipts` at `ee59b51` (two commits, four files).
- **Gate**: `tests/smoke.sh` on merged main printed `smoke: 203 passed`, exit 0. Before: 202. The new case: `watch events: a move receipt is a record and moved.by names the mover`.
- **Review**: standard. Round 1 asked for changes; round 2 approved at `ee59b51`.
- **Done-when**:
  1. `watch/references/events.md` items 4 and 5 describe a receipt as a record with `moved.by` as the mover, and "bare move with no comment" is gone. Met.
  2. The smoke case exists and smoke passes, quoted above. Met.
  3. README § Sizes matches `wc -w` (`events.md` 511, `responding.md` 376, watch total 1,716). Met.
- **Beyond the body's Change list**, by the lead's ruling on this thread:
  - item 5 says which receipt counts: the newest whose `moved.to.lane` is the card's current lane;
  - an agent's move is "context, never a work order";
  - `watch/references/responding.md` says "an owner's move" where it said "a bare move".
- **Known gap, not closed**: an agent's older receipt brought a card into a lane, the card left, and the owner returns it there with a bare `mv`. The newest receipt into that lane is the agent's, so the owner's return reads as an agent's move. A bare `mv` changes no stamp, so prose cannot tell the two apart; it would take a log or time check.
- **Unchecked**: a watch session reading a live receipt. No move in the app happened on a board with receipts on during the build.
- **For the release commit**, the changelog entry: "Watch now reads the receipt the app writes when you move a card as a record of that move, never answers it, and tells from it who moved the card."
