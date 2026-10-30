---
schema: 1
kind: card
title: "ADR: Runner jobs do their work through the work skill"
order: 2048
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-10-30T14:07:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T14:07:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Question: [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74)

Every job the runner starts does its work through `/lanework:work`, the skill an interactive session uses, not through job logic of the runner's own. The runner decides when a job starts and on which card. The work skill decides what the job does.

## Considered options

- Runner-specific prompts per job kind: a second copy of the board rules to keep in step with the skills.

## Consequences

- A change to the work skill changes every runner job, with no runner release.

## Related

- [PDR: Phase 1 runs board-side jobs and builds](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7ffd2bf2-15aa-4968-88b1-66bccbd86db5)
