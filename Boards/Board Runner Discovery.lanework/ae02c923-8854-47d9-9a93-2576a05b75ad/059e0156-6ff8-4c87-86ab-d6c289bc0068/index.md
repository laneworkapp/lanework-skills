---
schema: 1
kind: card
title: "Q11: The build trust gate"
order: 3072
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:19Z, comment: bfc87169-f201-4f17-a154-d12135ecdd48}
created:  {at: 2026-10-30T15:30:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
What must be true before a job builds a card?

## Options

- A: The owner moved the card into Approved: the move is unstamped or stamped `kind: human`.
- B: A, or the app's `shortcuts` automation moved it.
- C: Any move into Approved, whoever made it.

## Recommended

A. A build runs code unattended, so only the owner's own move is a go-ahead, as the pipeline lanes already say.

## Depends on

- [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74): board jobs and builds, through the work skill
