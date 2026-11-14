---
schema: 1
kind: card
title: "Taking over a card whose lease lapsed"
order: 15360
labels: [{text: "Round 4", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:07:50Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q15
---
How does an agent take a card whose lease has lapsed and whose holder never released it?

## Options

- A: It stakes as on a free card (write, wait, read back), then posts a short record naming the session it took over from and when that lease lapsed. It reads the thread for a START or a "lease lost" record first, since either may point at work to keep.
- B: The same, after a grace period of 5 minutes past `until`.
- C: It does not. A lapsed lease is reported, and the owner frees the card.

## Recommended

A. A lapsed lease already gave the holder 15 minutes of missed renewals, so a further grace adds little, and waiting on the owner brings back today's stale claims.

## Depends on

- [Q3: Staking a lease on a free card](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb): write, wait, read back
- [Q8: Releasing a lease](lanework://33527992-d72c-417b-85a2-1b62bea96794/0f36b65c-b027-461a-b9af-5c8db6e5fc5a): released in the closing write
- [Q9: A lost lease and the work in flight](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2): the work stays, the loser stops

## Ruling

**2026-11-14**: A, as recommended. "A: Stake as on a free card, then record who it took over from."
ADR: [ADR: A lapsed lease is taken over at once, with a record](lanework://33527992-d72c-417b-85a2-1b62bea96794/9a6850de-9571-4e7c-bacd-d0758a2bfa08)
