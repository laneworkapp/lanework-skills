---
schema: 1
kind: card
title: "Q9: Which changes reach the lane reader"
order: 1024
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:18Z, comment: 9680b488-0fa0-4aa0-ab86-8cea8988dfcd}
created:  {at: 2026-10-30T15:30:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Which board changes reach the model that reads the lanes?

## Options

- A: Owner-authored changes only: a comment, a move, a new card. Agent-stamped writes, the runner's own included, never reach it.
- B: Every card change except the runner's own writes, so an interactive agent's move can start a job too.
- C: Every change, bulk changes from a git pull included.

## Recommended

A. Owner authorship is the whole trigger, which also keeps the runner from triggering itself and keeps agent-written card text from starting jobs.

## Depends on

- [Q3: What starts a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1237c522-b375-407b-b9f7-13dc79b28cfd): the run skill owns its trigger rules
- [Q2: Where lane rules come from](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/40de41da-04d2-4980-b6b3-cfd4fb5a1c72): a small model reads the lane bodies
