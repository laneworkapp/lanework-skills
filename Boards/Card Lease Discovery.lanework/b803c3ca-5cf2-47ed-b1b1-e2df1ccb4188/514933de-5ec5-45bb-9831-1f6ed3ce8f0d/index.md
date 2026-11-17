---
schema: 1
kind: card
title: "Leases are seen through agents and reports, not on the board"
order: 12288
labels:
  - {text: "PDR", rank: 2, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:31:59Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: PDR1
---
Question: [Q17: Seeing held cards and freeing one by hand](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e173c4d-4af0-4b1a-b54d-c370ddf8a10f)

The owner sees leases through agents and reports, and nothing on the board marks a held card. Any agent asked runs the lease script's list, and sweep and watch reports list held cards and flag a lapsed lease. The owner frees a card by deleting its `claimed` line, or by telling an agent, which releases it by force and records that the owner said so. Nothing is added to the board that could go stale, and the lease stays one key.

## Considered options

- A `Held` label the script adds and removes: visible on the board, and left behind by a crashed holder until takeover.
- Asking the app to draw `claimed`: an app change outside this repo. It can follow later without changing this.

## Consequences

- A held card looks like any other in the app. Seeing it at a glance waits on the app.
- A forced release is the one lease write made by a session that is not the holder.
