---
schema: 1
kind: card
title: "PDR: The owner judges the proof of concept by use"
order: 8192
labels:
  - {text: "PDR", rank: 2, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T15:17:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T15:17:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q7: What counts as success](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/30ab959c-6258-462a-932b-05c7261d7067)

The proof of concept succeeds when the owner, after using the runner, judges that it works. There is no fixed measured bar. The owner chose this over the recommended week-long unattended bar.

## Considered options

- A week unattended on one real board, with every owner comment and Shaping move handled, no duplicate job, no job past its turn cap, nothing undone (recommended): a bar the experiment can fail.
- The same bar over a single day.

## Consequences

- Whether run replaces `/watch` and `/dispatch` rests on the owner's judgment, not a measured result.
