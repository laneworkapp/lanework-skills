---
schema: 1
kind: card
title: "Q4: One board or many per runner"
order: 4096
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-10-30T13:49:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T14:56:28Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
waiting: {for: rzen, since: 2026-10-30T14:56:28Z, comment: 6c91a823-1e3c-4427-89be-81ec894e4ba5}
---
Does one runner process watch one board or several?

## Options

- A: One board per process. launchd runs one per board.
- B: One process over several boards, as `watch` does.

## Recommended

A. One board path argument keeps the state simple, and it is the interface the app would hand the runner later.
