---
schema: 1
kind: card
title: "Q9: A lost lease and the work in flight"
order: 2048
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T14:02:58Z, comment: 9b980564-c170-4bfd-8a3b-1b3e77194dc1}
created:  {at: 2026-11-14T14:02:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:02:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
A holder that finds another session's `by` in its lease has already stopped and recorded the loss (Q3). What happens to the work it had in flight?

## Options

- A: It leaves the work where it is, names it in the "lease lost" record (branch, worktree, files touched), and never writes the card again. The new holder decides what to keep.
- B: It discards the in-flight work, so the new holder starts clean.
- C: It waits for the other lease to lapse, then stakes again and carries on.

## Recommended

A. Nothing is thrown away, the new holder sees what exists, and the loser cannot fight back for the card.

## Depends on

- [Q3: Staking a lease on a free card](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb): write, wait, read back, provisionally
- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
