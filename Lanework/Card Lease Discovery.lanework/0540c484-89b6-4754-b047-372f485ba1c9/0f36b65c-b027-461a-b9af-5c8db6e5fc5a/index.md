---
schema: 1
kind: card
title: "Releasing a lease"
order: 8192
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:02:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q8
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

## Ruling

**2026-11-14**: A, as recommended. "A: When it stops working the card, in its closing write."
