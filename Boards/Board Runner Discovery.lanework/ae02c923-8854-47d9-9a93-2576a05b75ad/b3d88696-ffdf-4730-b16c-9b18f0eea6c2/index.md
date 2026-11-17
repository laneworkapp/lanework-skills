---
schema: 1
kind: card
title: "Q10: The lane reader's model and output"
order: 2048
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:18Z, comment: c8c0e44e-b7fd-4357-a51d-88a88d7dcca6}
created:  {at: 2026-10-30T15:30:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Which model reads the lanes, and what does it hand back to the runner?

## Options

- A: Haiku, returning one fixed line per card: skip, or start a job with its role and a one-line brief.
- B: Sonnet, same fixed line.
- C: Haiku, returning a free-form prompt for the job.

## Recommended

A. Classifying a change against a lane body is mechanical, and a fixed line lets the script, not the model, decide what runs.

## Depends on

- [Q2: Where lane rules come from](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/40de41da-04d2-4980-b6b3-cfd4fb5a1c72): a small model reads the lane bodies
