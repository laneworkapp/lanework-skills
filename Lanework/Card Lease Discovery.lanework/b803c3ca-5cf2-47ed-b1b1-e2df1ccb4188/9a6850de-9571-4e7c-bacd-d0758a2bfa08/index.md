---
schema: 1
kind: card
title: "A lapsed lease is taken over at once, with a record"
order: 11264
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "superseded", rank: 3, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:24:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: ADR11
---
Question: [Q15: Taking over a card whose lease lapsed](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53)

An agent takes a card whose lease has lapsed without asking anyone and without a grace period: it stakes as on a free card (write, wait, read back), then posts a short record naming the session it took over from and when that lease lapsed. Before starting it reads the thread for a START or a "lease lost" record, since either may point at work to keep. A lapsed lease already means the holder missed its renewals, and waiting on the owner would bring back today's stale claims.

## Considered options

- A grace period of 5 minutes past `until`: little gained after 15 minutes of missed renewals.
- No takeover, the owner frees the card: a dead holder's card waits on a human, as a stale START does today.

## Consequences

- A holder that was only slow finds another session's `by` at its next renewal and stops, leaving its work in place.
- The takeover record is how a later reader tells a takeover from a first claim.

## Related

- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
- [ADR: A lost lease leaves the work in place, and the loser stops](lanework://33527992-d72c-417b-85a2-1b62bea96794/3b8d6e0b-1668-4e67-80ab-4a88fda8ad96)
