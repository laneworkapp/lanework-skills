---
schema: 1
kind: comment
created:  {at: 2026-11-17T21:23:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**More for this issue, from the review of [plan's claim-ticket lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5), 2026-11-17. None fixed there.**

In `skills/lanework/scripts/lease.sh`:

- **The timer starts before its process id is saved.** At the test poll of 0.2 seconds on a loaded machine, a timer reads an empty id at its first poll and exits. Reasoned by the reviewer from one failed smoke run in four run in parallel; harmless at the real 60-second poll. The smoke line it broke now tolerates a timer already gone.
- **A renewal can land the pre-resolve file on the Resolved path**, with `claimed` and without the Resolution. Reasoned, not measured; the same unlocked write as the first section of this card.

In `skills/plan/scripts/claim-ticket.sh`, on main:

- **A claim ended just before the card's move** leaves the ticket in Frontier with no lease but with `order` and `modified` restamped, so it can change place in the lane. Measured; the same before the lease.
- **A one-fork window**: another hand moving the card into Working between the claim's mark and its own move would leave the claim's stake on a card it never moved. Reasoned, not measured.
- **A claim ended by a signal that cannot be caught** strands its stake in Frontier; the same session's next claim recovers it. Measured.

In `tests/smoke.sh`:

- **The first plan claim case fails under load**: 3 of 5 runs with five smoke runs in parallel, and once with two. Never with one run at a time. Cause not isolated: the `until` check when a claim takes over 10 seconds, or the timer race above.
