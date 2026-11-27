---
schema: 1
kind: comment
created:  {at: 2026-11-27T13:03:19Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T13:03:19Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Ruled by the owner, 2026-11-27: the skill keeps its own full-featured healer. Proposal rewritten for that and moved to Proposed.**

- **The owner's words**: "the problem with A is should the board be in deep trouble where the app cant (or if its stale and the user just doesnt) open the board, its heal scrpit would be stale also. we end up in a kind of catch 22 situation. so no, the skill must have its own full featured healer."
- **Body changes**: § Options became § Ruled. Scope is now a hand port of the v6 rules into `skills/lanework/scripts/heal-board.py`, with no file from the app under `skills/`.
- **Follows from the ruling, decided in the body**: today the skills' healer refuses whenever the board ships its own. It now refuses only when the board's copy is at the same or a later heal version, so a stale board copy cannot block it.
- **Drift**: a smoke note and a release warning when the board's healer moves past the version the skills target.
- **Not taken**: A and C.
- **State**: in Proposed, at the review gate. Nothing waits on an agent.
