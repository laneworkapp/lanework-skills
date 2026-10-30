---
schema: 1
kind: card
title: "ADR: Every runner job starts fresh; the board is the memory"
order: 6144
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T15:14:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T15:14:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q5: Fresh job or resumed session](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/25fe03a3-f47b-4929-934b-e575d7ca7383)

Every runner job starts as a fresh session, even when it follows the owner's reply to an ask. It reads the card and its thread, and the board is the only memory. Resuming would carry old context forward, which is the growth the runner exists to avoid.

## Considered options

- Resume the card's last session by its id: nothing lost, but context grows with every round.
- Resume when the last session is under a day old: a middle path with a cut-off to tune.

## Consequences

- Anything a job needs later must be written on the card or its thread before the job ends.
