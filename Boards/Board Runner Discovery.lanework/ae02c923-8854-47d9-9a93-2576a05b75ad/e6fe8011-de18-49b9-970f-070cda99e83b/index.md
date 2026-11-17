---
schema: 1
kind: card
title: "Q16: A failed job"
order: 8192
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:21Z, comment: 6392f3b0-712a-472d-a46a-ab93bfd7fe73}
created:  {at: 2026-10-30T15:30:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
What happens when a job fails: a non-zero exit, or its turn cap reached?

## Options

- A: No retry. The runner posts a short record on the card naming the failure, releases the lease, and skips the card until the owner comments again.
- B: Retry once, then A.
- C: Retry until it succeeds.

## Recommended

A. A failed run repeated unattended is the runaway this design exists to prevent.

## Depends on

- [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74): board jobs and builds, through the work skill
- [Fact: headless runs cap turns exactly, spend only roughly](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/66603d6f-c6f3-4a8b-967c-7c5f8e0d35a6)
