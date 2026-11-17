---
schema: 1
kind: card
title: "Lease length and renewal"
order: 4096
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T13:45:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q4
---
How long does a lease last, and how does its holder keep it while the work runs?

## Options

- A: 30 minutes, renewed by the holder whenever under 15 minutes remain, at its next write or on a timer. An expired lease means the card is free.
- B: Fixed per kind of work, such as 30 minutes for board work and 3 hours for a build, never renewed.
- C: No expiry. The holder clears it when done, and a dead holder's lease waits for the owner.

## Recommended

A. One length keeps it simple, renewal covers a long build, and 30 minutes matches the silence after which `dispatch` already calls a START stale.


## Options, revised 2026-11-14

After the owner's comment: 30 minutes and renewal at 15 minutes left both stand. What remains is the first lease's length.

- A: 30 minutes fixed. Renewed when under 15 remain, by a timer while the work runs.
- B: The first lease sized to the agent's estimate, never under 30 minutes. Renewed the same way.

Recommended: A. Renewal on a timer covers a long blocking command, and an estimate only lengthens how long a dead holder's card stays taken.

## Depends on

- [Q1: What identifies a lease's holder](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb): the session id in `by`
- [Q14 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3): taken up here
- [Fact: a claim today is a START comment, and nothing frees a stale one](lanework://33527992-d72c-417b-85a2-1b62bea96794/b6961802-2324-4ba9-b03d-ea3e74eb9d1c)

## Ruling

**2026-11-14**: A, as recommended. "A: 30 minutes fixed. A timer renews it when under 15 remain." Earlier, on the first options: "30 minutes sounds right but i wonder if initial lease duration can be estimated based on expected workload? 15 minutes advance renewal sounds right."
ADR: [ADR: A lease runs 30 minutes, renewed by a timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/ce03dec0-06e0-4fa8-ac29-671c59ba6930)
