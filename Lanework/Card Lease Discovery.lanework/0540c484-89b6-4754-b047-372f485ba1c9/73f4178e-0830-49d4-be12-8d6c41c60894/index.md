---
schema: 1
kind: card
title: "Q2: One machine or several"
order: 2048
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T13:43:51Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
Must a lease keep two agents apart when they run on different machines, or only when they share one machine?

## Options

- A: One machine. Agents share one checkout of the board. Across machines the lease is only a hint, and that limit is written down.
- B: Across machines too. A pushed commit decides who holds the card.

## Recommended

A. Every session and runner today works one checkout, and B turns each claim and each renewal into a commit and a push.

## Depends on

- [Fact: a claim today is a START comment, and nothing frees a stale one](lanework://33527992-d72c-417b-85a2-1b62bea96794/b6961802-2324-4ba9-b03d-ea3e74eb9d1c)

## Ruling

**2026-11-14**: A, as recommended. "A: One machine. Across machines it is only a hint, and the limit is written down."
ADR: [ADR: A lease holds on one machine; across machines it is a hint](lanework://33527992-d72c-417b-85a2-1b62bea96794/94e3d45e-37cf-4c39-a633-87610ab297b4)
