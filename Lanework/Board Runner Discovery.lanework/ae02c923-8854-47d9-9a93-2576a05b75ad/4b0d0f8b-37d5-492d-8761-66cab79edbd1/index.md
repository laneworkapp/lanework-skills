---
schema: 1
kind: card
title: "Q6: How a card shows it is taken"
order: 6144
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T13:49:17Z, comment: bdf3a315-3500-4a03-b6b9-fbca0ce22fe1}
created:  {at: 2026-10-30T13:49:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
How does a card show that a job is working on it?

## Options

- A: State private to the runner, plus the START comment `work` already posts. Nothing new on the card.
- B: A lease key in card frontmatter, `claimed: {by, until}`, which interactive sessions also honor.
- C: Both.

## Recommended

A. Dispatch's state script already keeps an in-flight set, and the START comment already tells an interactive session the card is taken.

## Depends on

- [Fact: the board format has no claim or presence, and keeps unknown keys](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/da63a42c-f5f7-4d48-9cd6-d586800e0d78)
- [Fact: dispatch already routes board events by script](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/c03c4d8d-fd90-4522-a663-81f5ce48b634)
