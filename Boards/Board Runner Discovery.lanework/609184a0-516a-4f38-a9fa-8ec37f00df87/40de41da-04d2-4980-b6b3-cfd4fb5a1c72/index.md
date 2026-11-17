---
schema: 1
kind: card
title: "Q2: Where lane rules come from"
order: 2048
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-10-30T13:49:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T14:50:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
With no model in the loop, how does the runner know what a lane asks of it?

## Options

- A: The Pipeline lane actors table, matched by lane title, as `watch` and `dispatch` read lanes today.
- B: A runner-only key in each lane's frontmatter, such as `runner: {on_enter: shape}`.
- C: A small model job reads the lane bodies on each event.

## Recommended

A. The actors table is already machine-readable, so every pipeline board works unchanged and nothing new enters the format.

## Ruling

**2026-10-30**: C, over the recommended A. "C: A small model job reads the lane bodies on each event."
ADR: [ADR: A small model reads lane bodies to pick each job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/5096c371-f91c-4392-b8a2-0470fede5f2d)
