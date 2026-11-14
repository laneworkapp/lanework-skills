---
schema: 1
kind: card
title: "Q8: Releasing a lease"
order: 1024
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T14:02:57Z, comment: 3492b611-b495-4f54-9132-0aa21ed3b357}
created:  {at: 2026-11-14T14:02:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:02:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
When does a holder give a lease back, so that a card is free as soon as nobody is working it?

## Options

- A: When it stops working the card: done, handed to a human gate, or given up. It deletes `claimed` in the same write as its closing comment or move.
- B: Never. The lease runs out on its own within 30 minutes.
- C: Only when the card moves to Done.

## Recommended

A. A card waiting at a gate or given up is free at once, rather than looking taken for up to 30 minutes.

## Depends on

- [Q3: Staking a lease on a free card](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb): write, wait, read back, provisionally
- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
