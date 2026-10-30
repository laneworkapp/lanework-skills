---
schema: 1
kind: card
title: "Q13: Jobs running at once"
order: 5120
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:20Z, comment: 05901f02-7e69-46a0-b580-a00a2be3d27b}
created:  {at: 2026-10-30T15:30:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
How many jobs may run at once on a board?

## Options

- A: One. The next waits for the running job to exit.
- B: Several board-side jobs, and at most one build.
- C: No cap beyond the work skill's free-memory check for builds.

## Recommended

A. The output streams to one terminal, and one job at a time keeps it readable and leaves no lease races.

## Depends on

- [Q4: One board or many per runner](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/08f2ee0c-c072-4233-b4a2-60841345b416): one board per process
- [Q8: What the owner sees of a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7eb05b54-d522-4a92-a4ea-8371161aced5): jobs stream live to the terminal
