---
schema: 1
kind: card
title: "A lease holds on one machine; across machines it is a hint"
order: 2048
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T13:43:51Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: ADR2
---
Question: [Q2: One machine or several](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894)

A lease keeps agents apart only when they share one checkout of the board on one machine. Across machines it is a hint that arrives with a pull, and the skills say so. Every session and runner today works one checkout, and holding across machines would turn each claim and each renewal into a pushed commit.

## Considered options

- Across machines, a pushed commit deciding the holder: every claim and renewal becomes a commit and a push, and claiming needs a reachable remote.

## Consequences

- Two agents on two machines can both work one card. The skills name that limit where they describe the lease.
