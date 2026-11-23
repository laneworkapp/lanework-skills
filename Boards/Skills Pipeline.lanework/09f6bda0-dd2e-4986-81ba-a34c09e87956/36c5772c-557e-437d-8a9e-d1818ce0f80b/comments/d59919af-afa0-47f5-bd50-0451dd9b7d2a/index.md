---
schema: 1
kind: comment
in-reply-to: 8de29686-da67-4b1d-a959-f26e906e1442
created:  {at: 2026-11-23T16:39:09Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:39:09Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Not the trial yet: this run counts 50 cards from before leases existed. Counted from the first lease, the total is 39 of 50, all clean.**

- **Your run**: `--since 2026-10-21` reaches a month before v0.9.0 (2026-11-21), when sessions began staking leases. Its 50 cards carry START records with no lease behind them.
- **Same board from the first lease** (`--since 2026-11-21T13:14:33Z`): `leased cards: 0`. No card on Lanework Pipeline has been started under a lease yet.
- **All 62 boards under the Lanework repos**, same `--since`, `--first 50`, run 2026-11-23: `leased cards: 39, lease lost: 0, two STARTs: 0, lapsed: 0`. Skills Pipeline alone: 19.
- **The card stays in Active**: 11 more leased cards, then one run with `--first 50` closes it.
