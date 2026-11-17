---
schema: 1
kind: card
title: "Q8: What the owner sees of a job"
order: 8192
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-10-30T13:49:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:26:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
What does the owner see of each job?

## Options

- A: One stdout line per job (card, start, end, cost, exit), the full transcript in a log folder outside the board, and the job's own record comment on the card.
- B: A, plus the transcript attached to the card.
- C: The stdout line and the card only, no transcript kept.

## Recommended

A. Transcripts stay out of git and the board, and one line per job is what the app could show later.

## Depends on

- [Fact: a headless session can be resumed by id](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1a99a2ff-d429-4f9d-aa47-3616cbefb7f6)

## Ruling

**2026-10-30**: Streaming plus C, over the recommended A. "lets try streaming job stdout to the terminal at least for the initial implementation." Then: "C: Keep nothing. The stream and the card's record comment are all."
PDR: [PDR: Jobs stream live to the terminal; no transcript is kept](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/c07b5ffe-bacd-4284-9355-a1505942d833)
