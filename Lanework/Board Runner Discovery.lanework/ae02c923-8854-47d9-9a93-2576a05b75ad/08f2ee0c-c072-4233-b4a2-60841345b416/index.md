---
schema: 1
kind: card
title: "Q4: One board or many per runner"
order: 4096
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T13:49:17Z, comment: b5b5b782-6b21-4770-a39b-d3530e5c7910}
created:  {at: 2026-10-30T13:49:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Does one runner process watch one board or several?

## Options

- A: One board per process. launchd runs one per board.
- B: One process over several boards, as `watch` does.

## Recommended

A. One board path argument keeps the state simple, and it is the interface the app would hand the runner later.
