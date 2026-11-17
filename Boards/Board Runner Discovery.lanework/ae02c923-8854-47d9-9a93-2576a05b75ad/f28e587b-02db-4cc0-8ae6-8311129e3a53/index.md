---
schema: 1
kind: card
title: "Q12: Unattended permissions"
order: 4096
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:19Z, comment: 5633cf92-cf68-44b2-ac85-c6bc3afd5a44}
created:  {at: 2026-10-30T15:30:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
What may a job do without asking, given that nobody is there to approve a prompt?

## Options

- A: `dontAsk` with an allowlist per job kind. Board jobs edit the board and commit. Build jobs also edit in their worktree and run the gate commands the board's instruction sheet names.
- B: Board jobs as in A, build jobs in `bypassPermissions` inside their worktree.
- C: `bypassPermissions` for every job.

## Recommended

A. A denial ends that step, not the job, and the stream shows exactly which rule to widen.

## Depends on

- [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74): board jobs and builds, through the work skill
- [Fact: a headless run denies unapproved tools and keeps going](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/86811770-7776-4d09-a879-da17e1133e60)
