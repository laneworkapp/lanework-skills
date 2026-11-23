---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:47:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:47:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Proposal finished: both calls ruled, moved to Proposed for review.**

- **Decided**: relations are the only record (ruled A). Old body lists are ignored and migrated by hand by test users, with no reader for the old shape and no migration script.
- **My reading, for you to check at review**: `--depends` is refused on a board below guide v111. A relation written there fails the board's own validator, and a body list would be ignored. If you would rather it wrote the relation anyway, bounce the card.
- **Accepted limitation**: on the AUP Skills Plan board (v109, 9 tickets with a body list) every Blocked ticket shows as drift until its dependencies are re-entered as relations, and resolving a ticket unblocks nothing from a body list.
- **Release**: minor.
