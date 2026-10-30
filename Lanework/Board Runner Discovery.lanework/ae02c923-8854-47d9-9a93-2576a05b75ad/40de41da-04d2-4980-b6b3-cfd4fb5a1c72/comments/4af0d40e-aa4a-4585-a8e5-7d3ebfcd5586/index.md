---
schema: 1
kind: comment
created:  {at: 2026-10-30T14:08:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T14:08:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
in-reply-to: 7739bff1-94d3-4b25-88df-e01d5395d94e
---
**In plain terms: when a card lands in a lane, how does the runner know what job to start?**

The runner is a script, not a model. It sees a card arrive in a lane and must pick a job without reading prose. This decides where that "lane means job" rule lives.

- **A** uses the table the skills already ship: Shaping means shape, Approved means build, matched by lane name. Every pipeline board works today. A renamed lane would not match.
- **B** adds a new setting to each lane's file naming its job. Explicit and survives renames. It is a new key every board must carry.
- **C** has a small model read each lane's description on every event. Handles any board. It costs a model call per event and can misread.

Why now: [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74) settled which jobs exist. This settles how the runner picks one.
