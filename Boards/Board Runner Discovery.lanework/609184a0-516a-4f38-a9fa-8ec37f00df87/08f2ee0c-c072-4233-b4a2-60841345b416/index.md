---
schema: 1
kind: card
title: "Q4: One board or many per runner"
order: 4096
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-10-30T13:49:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:12:39Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Does one runner process watch one board or several?

## Options

- A: One board per process. launchd runs one per board.
- B: One process over several boards, as `watch` does.

## Recommended

A. One board path argument keeps the state simple, and it is the interface the app would hand the runner later.

## Ruling

**2026-10-30**: A, as recommended. "A: One board per process. launchd runs one per board."
ADR: [ADR: One runner process per board](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/d1fc0024-bfe6-4cd0-b634-796d2224ed9a)
