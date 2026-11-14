---
schema: 1
kind: card
title: "Q4: Lease length and renewal"
order: 2048
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T13:45:41Z, comment: 2bc58bf8-95ce-418c-993c-0368814ed987}
created:  {at: 2026-11-14T13:45:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:45:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
How long does a lease last, and how does its holder keep it while the work runs?

## Options

- A: 30 minutes, renewed by the holder whenever under 15 minutes remain, at its next write or on a timer. An expired lease means the card is free.
- B: Fixed per kind of work, such as 30 minutes for board work and 3 hours for a build, never renewed.
- C: No expiry. The holder clears it when done, and a dead holder's lease waits for the owner.

## Recommended

A. One length keeps it simple, renewal covers a long build, and 30 minutes matches the silence after which `dispatch` already calls a START stale.

## Depends on

- [Q1: What identifies a lease's holder](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb): the session id in `by`
- [Q14 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3): taken up here
- [Fact: a claim today is a START comment, and nothing frees a stale one](lanework://33527992-d72c-417b-85a2-1b62bea96794/b6961802-2324-4ba9-b03d-ea3e74eb9d1c)
