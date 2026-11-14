---
schema: 1
kind: card
title: "Q20: How the lease is judged to work"
order: 19456
labels: [{text: "Round 5", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:32:35Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:36:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
How is the lease judged to work, once built?

## Options

- A: Two measures. Smoke cases for every ruling on throwaway boards: two racing stakes leave one holder, renewal, a lost lease, the clock guard, takeover, release, a forced release. And a trial on the live boards: over the first 50 cards worked under a lease, no "lease lost" record, no card with two START comments from different sessions inside one lease, and no card left held by a dead session past its `until`.
- B: Smoke cases only.
- C: The live trial only.

## Recommended

A. Smoke shows the script does what was ruled, and only live use shows whether the provisional staking of Q3 collides in practice.

## Depends on

- [Q3: Staking a lease on a free card](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb): write, wait, read back, provisionally
- [Q14: The clock guard: what it checks and on what basis](lanework://33527992-d72c-417b-85a2-1b62bea96794/df8b2a68-f17a-444c-97c6-74fa972795c3): a range check against now
- [Q15: Taking over a card whose lease lapsed](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53): taken over at once, with a record

## Ruling

**2026-11-14**: A, as recommended. "A: Smoke cases for every ruling, plus a clean trial over the first 50 leased cards."
PDR: [PDR: The lease works when smoke passes and 50 leased cards run clean](lanework://33527992-d72c-417b-85a2-1b62bea96794/67912ed8-4595-4514-8a6f-a5a629b473c8)
