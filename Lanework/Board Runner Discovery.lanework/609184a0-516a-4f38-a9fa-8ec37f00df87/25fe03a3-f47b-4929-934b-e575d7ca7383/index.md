---
schema: 1
kind: card
title: "Q5: Fresh job or resumed session"
order: 5120
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-10-30T13:49:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:14:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
When the owner replies to an ask, does the next job resume the earlier session or start fresh?

## Options

- A: Always fresh. Each job reads the card and its thread, and the board is the memory.
- B: Resume the card's last session by its id.
- C: Resume when the last session is under a day old, else fresh.

## Recommended

A. Resuming carries the old context forward, which is the growth this experiment exists to avoid, and the thread already holds the record.

## Depends on

- [Fact: a headless session can be resumed by id](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1a99a2ff-d429-4f9d-aa47-3616cbefb7f6)

## Ruling

**2026-10-30**: A, as recommended. "A: Always fresh. Each job reads the card and its thread, and the board is the memory."
ADR: [ADR: Every runner job starts fresh; the board is the memory](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1dca8624-d885-449d-941d-cbe50cecab03)
