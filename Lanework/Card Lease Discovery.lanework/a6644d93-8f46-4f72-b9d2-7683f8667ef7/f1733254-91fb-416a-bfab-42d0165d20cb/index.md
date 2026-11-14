---
schema: 1
kind: card
title: "Q3: Staking a lease on a free card"
order: 1024
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T13:45:39Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:51:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
waiting: {for: anyone, since: 2026-11-14T13:51:06Z, comment: 73c4b2f7-e7de-49c0-89aa-a477c6e06c3e}
---
How does an agent stake a lease on a free card, so that when two agents on one machine reach for the same card, exactly one ends up holding it?

## Options

- A: Write `claimed`, wait a second, read it back. If `by` is no longer yours, the other agent won, so back off.
- B: Take a lock first (an atomic `mkdir` in a temp folder keyed by board and card), write `claimed`, then drop the lock.
- C: Stake by moving the card's folder to a lane, as `plan` does, and write `claimed` after the move.

## Recommended

A. On one machine a write followed by a read-back settles the race without a lock file to leak or a lane to reserve, and the loser can tell it lost.


## Options, revised 2026-11-14

After the owner asked whether a collision can be detected, so that A can go ahead provisionally:

- A: Write, wait a second, read back. Each renewal reads \`by\` first and records a lost lease. Revisit if one is ever recorded.
- B: Take an atomic temp-folder lock, write, drop the lock.
- C: Move the card to a lane, then write.

Recommended: A, provisionally. A collision is caught by the next renewal and counted from the records, and B stays the fallback.

## Depends on

- [Q1: What identifies a lease's holder](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb): the session id in `by`
- [Q2: One machine or several](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894): one machine, a hint across machines
- [Fact: plan claims a ticket by moving it to Working](lanework://33527992-d72c-417b-85a2-1b62bea96794/361cdb21-6f7c-4c29-a0ed-cf9ab06cb2b9)
