---
schema: 1
kind: card
title: "A holder back late finds its own lease lapsed"
order: 16384
labels: [{text: "Round 4", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:07:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q16
---
A holder comes back late, for example after the machine slept, and finds its lease lapsed but still carrying its own `by`. Nobody took the card. What does it do?

## Options

- A: It renews and carries on. The lease is still its own, and nobody else staked.
- B: It treats a lapsed lease as lost, stops, and records it, as if another session had taken the card.

## Recommended

A. After a sleep every timer wakes at once and each holder renews its own cards, so nothing is lost. If another session did take the card, `by` differs and the lost-lease rule applies.

## Depends on

- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
- [Q9: A lost lease and the work in flight](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2): the work stays, the loser stops

## Ruling

**2026-11-14**: A, as recommended. "A: Renew and carry on."
Added by the owner a moment later: "assuming noone took over". That is the case the question asks about: if another session took the card, `by` differs and [Q9](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2) applies.
