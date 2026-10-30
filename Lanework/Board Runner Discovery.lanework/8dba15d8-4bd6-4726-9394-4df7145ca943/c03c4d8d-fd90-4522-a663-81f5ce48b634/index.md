---
schema: 1
kind: card
title: "Fact: dispatch already routes board events by script"
order: 5120
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-10-30T13:48:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
`dispatch` already sorts board events with a script, not a model: comment, move, body, bulk, self, excluded, with the owner told apart by stamps. Its routing table sends an owner comment, an owner move into an agent lane, and a bulk change to a fresh handler; everything else is dropped. Its state script keeps an in-flight set, per-card queues and a self-writes registry. The handler is a subagent today; nothing in it depends on being one.

## Source

- `skills/dispatch/` on `main`, read 2026-10-30. Report attached.

## Bears on

- [Q3: What starts a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1237c522-b375-407b-b9f7-13dc79b28cfd)
- [Q6: How a card shows it is taken](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1)
