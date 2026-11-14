---
schema: 1
kind: card
title: "A subagent shares its session's id"
order: 7168
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T13:45:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q7
---
Q1 settled a lease's holder as the harness session id, and a subagent shares its parent session's id. So a session's subagents all read as one holder. Which holds?

## Options

- A: The session is the holder. Its subagents work under the session's leases and never stake their own: the session stakes before handing a card off and releases after.
- B: A subagent adds an `agent` subkey to `by`, so the holder is the session id plus that name.
- C: Accept it. A session and its subagents count as one holder, and each subagent stakes as the session.

## Recommended

A. `dispatch` and a build lead already hand each card to one subagent, so the session knows who works what, and the lease keeps Q1's one shape.

## Depends on

- [Q1: What identifies a lease's holder](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb): the session id in `by`
- [Fact: a subagent shares its parent session's id](lanework://33527992-d72c-417b-85a2-1b62bea96794/e3ffb17b-9813-4861-ab7c-012899af2742)

## Ruling

**2026-11-14**: A, as recommended. "A: The session. Its subagents work under its leases and never stake."
ADR: [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
