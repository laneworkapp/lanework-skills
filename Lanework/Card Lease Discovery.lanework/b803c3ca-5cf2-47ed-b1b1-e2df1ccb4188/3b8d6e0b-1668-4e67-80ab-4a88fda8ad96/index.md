---
schema: 1
kind: card
title: "ADR: A lost lease leaves the work in place, and the loser stops"
order: 7168
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:04:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:04:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Question: [Q9: A lost lease and the work in flight](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2)

A holder that finds another session's `by` in its lease stops, posts one "lease lost" record naming the work it had in flight (branch, worktree, files touched), and after that record never writes the card again. The work stays where it is, and the new holder decides what to keep. Nothing is thrown away, and the loser cannot fight back for the card.

## Considered options

- The loser discards its in-flight work: the new holder starts clean, at the cost of work that may have been the further along.
- The loser waits for the other lease to lapse and stakes again: two sessions take turns on one card, each building on a state the other changed.

## Consequences

- The "lease lost" record is the loser's last write to the card, and the one write it makes without holding the lease.
- A new holder reads the thread for a "lease lost" record before starting, since it may point at usable work.

## Related

- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74): renewal is where the loss is found
