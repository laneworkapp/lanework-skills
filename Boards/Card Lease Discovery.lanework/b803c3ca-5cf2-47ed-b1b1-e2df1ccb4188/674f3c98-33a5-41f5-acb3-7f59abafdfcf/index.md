---
schema: 1
kind: card
title: "The clock guard is a range check against now, with an elapsed-time timer"
order: 10240
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:16:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: ADR10
---
Question: [Q14: The clock guard: what it checks and on what basis](lanework://33527992-d72c-417b-85a2-1b62bea96794/df8b2a68-f17a-444c-97c6-74fa972795c3)

A reader treats a lease whose `until` is more than 35 minutes ahead of now as no lease: the card is free, and whoever stakes it records that it ignored one. The holder's timer renews every 15 minutes of elapsed time, counted by waiting and never by reading `until`, and each renewal rewrites `until` from the clock as it is then. The basis is that a lease is 30 minutes long, so now is the one value a wrong clock at write time did not also produce.

## Considered options

- `until` within 30 minutes of the card's `modified.at`: both are written from the same clock in the same write, so a wrong clock passes. It only catches an `until` the script did not write.
- Both checks: one extra case caught, for a second rule on every read.
- The card file's time on disk: reset by an app edit, a pull or a checkout.

## Consequences

- A lease written under a wrong clock repairs itself within 15 minutes, at the holder's next renewal.
- A clock running behind is not guarded. A live lease then looks lapsed, another agent may take the card, and the holder finds out at its next renewal and stops.
- An error under 35 minutes passes, and costs at most 35 minutes.

## Related

- [ADR: A lease runs 30 minutes, renewed by a timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/ce03dec0-06e0-4fa8-ac29-671c59ba6930): "renew when under 15 remain" is carried out as every 15 minutes of elapsed time
- [Q13: A wrong clock in until](lanework://33527992-d72c-417b-85a2-1b62bea96794/df0483a6-4636-464f-b31c-83fa219e9eea): the ruling that a guard is wanted
