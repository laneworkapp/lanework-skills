---
schema: 1
kind: card
title: "ADR: The run skill owns its trigger rules"
order: 4096
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T14:52:35Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T14:52:35Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q3: What starts a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1237c522-b375-407b-b9f7-13dc79b28cfd)

The run skill owns its trigger rules: which board events start a job are written for the runner and live in the run skill, not reused from dispatch's classifier and routing table. The owner wants the skill self-sufficient because, if it succeeds, it becomes the primary watch skill and displaces `/watch` and `/dispatch`.

## Considered options

- Dispatch's routing table as it is (recommended): only the spawn changes, but the runner then depends on a skill it is meant to replace.
- Dispatch's table minus bulk changes: the same dependency.

## Consequences

- Trigger rules exist twice while `/watch` and `/dispatch` still ship, and can drift until those are retired.
