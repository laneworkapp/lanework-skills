---
schema: 1
kind: comment
created:  {at: 2026-11-27T12:57:40Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:57:40Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped and moved to Proposed: a card whose lane was deleted goes to the trash, or to its other live lane.**

- **Reproduced** on a throwaway repo, three ways: ours removes the lane, theirs removes it, and a card moved into a lane the other side removed. Each time the card ends up in a lane folder with no `index.md`, the pass exits 0 and reports "validates".
- **Why it matters**: the app skips a lane with no `index.md` and every card in it, so the kept edit is invisible. The validator and the heal both pass over it.
- **Cause**: one fallback in `process_card`, `skills/merge/scripts/lanework-merge.py` line 956, falls back to the gone lane itself.
- **Proposed**: the lane's trashed copy, else the card's other live location, else `.trash/<card>`, restamped so it sorts on top, with a merge comment saying why. One shared rule for `process_card` and `restore_deleted`.
- **Not taken**: restoring the deleted lane, or moving the card to the first lane. Either can drop a card into an agent lane and start work nobody asked for.
- **Open calls**: none.
- **Order**: it touches the same test lines as the v122 card, so it builds after that one lands.
- **State**: in Proposed, at the review gate.
