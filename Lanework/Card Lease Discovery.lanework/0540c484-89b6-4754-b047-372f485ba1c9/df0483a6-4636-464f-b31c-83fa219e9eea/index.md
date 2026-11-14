---
schema: 1
kind: card
title: "Q13: A wrong clock in until"
order: 13312
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:03:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:07:50Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
A lease's `until` is a time, and a wrong clock would make it lapse early or hold too long. Does the lease need a guard against a wrong clock?

## Options

- A: No guard. On one machine (Q2) every holder reads the same clock, and `until` is written in UTC from it, as stamps are.
- B: A guard: before trusting `until`, compare it with the card file's own modification time, and treat a lease more than an hour out as suspect.

## Recommended

A. With one machine there is one clock, so a wrong clock is wrong for every agent at once and no lease is unfair to another.

## Depends on

- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
- [Q2: One machine or several](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894): one machine, a hint across machines

## Ruling

**2026-11-14**: Yes, a guard. "yes but lets discuss exactly how to impose the guard and on what basis"
The check in option B is not ruled. [Q14: The clock guard: what it checks and on what basis](lanework://33527992-d72c-417b-85a2-1b62bea96794/df8b2a68-f17a-444c-97c6-74fa972795c3) asks how and on what basis.
