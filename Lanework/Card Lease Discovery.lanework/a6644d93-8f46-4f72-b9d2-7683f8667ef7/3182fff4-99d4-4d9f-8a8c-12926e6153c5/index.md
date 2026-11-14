---
schema: 1
kind: card
title: "Q6: Merging two differing leases"
order: 4096
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T13:45:43Z, comment: 0ecd0c20-ffee-40e8-a81c-10d2477b1532}
created:  {at: 2026-11-14T13:45:43Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:45:43Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
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
