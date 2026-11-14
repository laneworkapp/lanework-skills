---
schema: 1
kind: card
title: "Q5: Which skills take a lease, and the START comment"
order: 5120
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T13:45:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:55:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
Which skills take a lease before working a card, and does the START comment stay once the lease is the claim?

## Options

- A: Every skill that starts work on a card (`work`, `watch`, `dispatch`, `plan`, the runner) takes a lease. The START comment stays as the journal's plan, and stops being a claim.
- B: Every such skill takes a lease, and the START comment goes.
- C: Only runner jobs and `dispatch` take a lease. Interactive sessions keep claiming with START.

## Recommended

A. Board Runner Discovery already ruled that interactive sessions honor the lease, and the START comment still carries the plan a cold reader needs.


## Options, revised 2026-11-14

After the owner asked whether START can be less verbose once it is no longer the claim:

- A: Every skill that starts work takes a lease. START stays as a short plan: one line, then Scope, Verify and Where, about 40 words.
- B: Every such skill takes a lease, and START goes. The first decision record carries the plan.
- C: Only runner jobs and `dispatch` take a lease. Interactive sessions keep claiming with START.

Recommended: A. The lease says who and until when, the short START says what, and its session stamp is how a collision is found afterwards.

## Depends on

- [Q1: What identifies a lease's holder](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb): the session id in `by`
- [Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1): interactive sessions honor the lease
- [Fact: a claim today is a START comment, and nothing frees a stale one](lanework://33527992-d72c-417b-85a2-1b62bea96794/b6961802-2324-4ba9-b03d-ea3e74eb9d1c)

## Ruling

**2026-11-14**: A, as recommended. "A: Every skill that starts work. START shrinks to a short plan." Earlier: "if the value/purpose of start changes, perhaps we can make it less verbose? wdyt?"
ADR: [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
