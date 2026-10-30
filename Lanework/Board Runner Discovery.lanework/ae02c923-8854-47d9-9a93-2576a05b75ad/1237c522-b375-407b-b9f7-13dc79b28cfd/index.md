---
schema: 1
kind: card
title: "Q3: What starts a job"
order: 3072
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T13:49:16Z, comment: 6dc2f3fa-b15b-43da-a90a-700732847179}
created:  {at: 2026-10-30T13:49:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Which board events start a job?

## Options

- A: Dispatch's routing table as it is: an owner comment anywhere, an owner move into an agent lane, a bulk change.
- B: The same table minus bulk changes, which are logged and skipped.
- C: New trigger rules written for the runner.

## Recommended

A. Reusing the classifier and routing table means only the spawn changes, from a subagent to `claude -p`.

## Depends on

- [Fact: dispatch already routes board events by script](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/c03c4d8d-fd90-4522-a663-81f5ce48b634)
