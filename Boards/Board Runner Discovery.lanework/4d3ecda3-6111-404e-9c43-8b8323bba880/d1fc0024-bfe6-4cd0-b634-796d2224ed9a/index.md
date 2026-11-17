---
schema: 1
kind: card
title: "ADR: One runner process per board"
order: 5120
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T15:12:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T15:12:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q4: One board or many per runner](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/08f2ee0c-c072-4233-b4a2-60841345b416)

Each runner process watches exactly one board, and launchd runs one process per board. One board path argument keeps state simple and isolates faults, and it is the interface the app would later hand the runner.

## Considered options

- One process over several boards, as `/watch` does: one shared cap on builds and model calls, but one crash stops every board and all state must be keyed by board.

## Consequences

- Nothing caps concurrent builds or model calls across boards. A cross-board limit, if needed, sits outside the runner.
