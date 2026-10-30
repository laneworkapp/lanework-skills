---
schema: 1
kind: card
title: "ADR: A small model reads lane bodies to pick each job"
order: 3072
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T14:50:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T14:50:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q2: Where lane rules come from](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/40de41da-04d2-4980-b6b3-cfd4fb5a1c72)

The runner learns what a lane asks of it from a small model job that reads the lane bodies on each event, not from the skills' lane actors table or a runner-only key. The owner chose this over the recommended actors table, so boards whose lanes are renamed or carry their own policy still get the right job.

## Considered options

- The Pipeline lane actors table, matched by lane title (recommended): no model call, but a renamed lane matches nothing.
- A runner-only key in each lane's frontmatter: explicit, but a new key every board must carry.

## Consequences

- Every event costs a model call before any job starts, and a misread lane body starts the wrong job.
