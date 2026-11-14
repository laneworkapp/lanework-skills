---
schema: 1
kind: card
title: "Q13: A wrong clock in until"
order: 6144
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T14:03:04Z, comment: 8bee2534-8a07-43cb-81e8-37bc9f7d8854}
created:  {at: 2026-11-14T14:03:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:03:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
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
