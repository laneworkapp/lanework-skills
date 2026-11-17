---
schema: 1
kind: card
title: "PDR: Phase 1 runs board-side jobs and builds"
order: 1024
labels:
  - {text: "PDR", rank: 2, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T14:07:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T14:07:51Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74)

Phase 1 of the runner takes on board-side jobs and builds of Approved cards: shaping, answering owner comments, folding rulings, and the worktree, fixer and reviewer build cycle. The owner chose this over the recommended board-side-only start.

## Considered options

- Board-side only first (recommended): tests continuous running and flat context without build risks.
- Everything the agent lanes allow from day one, builds gated on free memory.

## Consequences

- Build risks (worktrees, memory, trust) arrive in phase 1, so the permission, trust-gate and success questions must cover builds.

## Related

- [ADR: Runner jobs do their work through the work skill](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/94e4cee5-a0f5-4793-8707-f5ac0681785c)
