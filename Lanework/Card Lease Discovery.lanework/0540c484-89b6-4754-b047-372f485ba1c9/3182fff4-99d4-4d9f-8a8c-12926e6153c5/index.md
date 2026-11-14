---
schema: 1
kind: card
title: "Merging two differing leases"
order: 6144
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T13:45:43Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q6
---
When a git merge meets two different leases on one card, which one does the `merge` skill keep?

## Options

- A: No special rule. `claimed` is state like any other key, so the side with the later `modified` stamp wins.
- B: The lease with the later `until` wins, whatever the stamps say.
- C: Drop both, so the card is free after the merge.

## Recommended

A. Across machines a lease is only a hint, so the merge needs no rule of its own, and `merge` already settles state by the later stamp.

## Depends on

- [Q2: One machine or several](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894): one machine, a hint across machines

## Ruling

**2026-11-14**: A, as recommended. "A: No special rule. The later `modified` stamp wins, as for other state."
