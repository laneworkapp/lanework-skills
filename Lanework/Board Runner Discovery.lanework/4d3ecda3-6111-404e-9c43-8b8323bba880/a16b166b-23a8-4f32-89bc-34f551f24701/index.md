---
schema: 1
kind: card
title: "ADR: A lease key in card frontmatter marks a taken card"
order: 7168
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T15:16:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T15:16:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q6: How a card shows it is taken](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1)

A job marks the card it works on with a lease key in the card's frontmatter, `claimed: {by, until}`, and interactive sessions honor it too. The owner chose this over runner-private state plus the START comment, so a claim is visible on the card itself to every session.

## Considered options

- Runner-private state plus the START comment `work` already posts (recommended): nothing new on the card, but only the runner sees its own in-flight set.
- Both the lease and private state.

## Consequences

- `/lanework:work` and every session that works cards must read and honor `claimed`, a key the app preserves but does not show.
- A job that dies holds its card until `until` passes.
