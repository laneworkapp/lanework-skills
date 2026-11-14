---
schema: 1
kind: card
title: "Staking writes, waits and reads back, provisionally"
order: 3072
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T13:52:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: ADR3
---
Question: [Q3: Staking a lease on a free card](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb)

An agent stakes a free card by writing `claimed`, waiting a second and reading it back. If `by` is no longer its own, another agent won and it backs off. The choice is provisional: every renewal reads `by` first and records a lost lease, and one such record is the trigger to revisit.

## Considered options

- An atomic `mkdir` lock in a temp folder around the write: no gap, at the cost of a lock to leak. The fallback if a collision is ever recorded.
- Staking by moving the card to a lane: makes a lane mean both stage and holder, and needs a "taken" lane on every board kind.

## Consequences

- A stall of over a second between an agent's read and its write lets two agents both believe they hold the card, until the overwritten one's next renewal.
- The "lease lost" record has one fixed wording, so collisions can be counted. Two START comments from different sessions within one lease are a collision too.
