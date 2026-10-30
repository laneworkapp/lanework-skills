---
schema: 1
kind: card
title: "PDR: Jobs stream live to the terminal; no transcript is kept"
order: 9216
labels:
  - {text: "PDR", rank: 2, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T15:26:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T15:26:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q8: What the owner sees of a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7eb05b54-d522-4a92-a4ea-8371161aced5)

The owner watches each job live: its output streams to the runner's terminal, at least in the initial implementation. No transcript is kept afterwards, so the stream and the job's record comment on the card are all there is.

## Considered options

- One stdout line per job and the full transcript in a log folder outside the board (recommended): a past job can be inspected.
- The same, plus the transcript attached to the card.

## Consequences

- A job that went wrong while nobody watched is known only from its record comment.
- Under launchd there is no terminal, so the stream lands in launchd's log file.
