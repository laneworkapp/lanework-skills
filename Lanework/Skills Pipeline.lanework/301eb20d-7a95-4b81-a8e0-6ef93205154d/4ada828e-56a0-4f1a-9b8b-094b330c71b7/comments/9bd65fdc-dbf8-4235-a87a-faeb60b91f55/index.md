---
schema: 1
kind: comment
created:  {at: 2026-10-25T16:33:01Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T16:33:01Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
in-reply-to: 2129b344-35ca-4017-8364-2f14cb6d7621
---
**Stale-claim rule ruled A: a START with no later comment for 30 minutes. A is a sound middle ground, and the card now moves to Proposed.**

- **Why A fits**: it catches a dead handler within half an hour and needs no session id, which dispatch handlers don't have. Wrongly flagging a live build costs one report line, since nothing is auto-released.
- **Its weak spot**: a build silent for 30 minutes gets flagged while alive. Leads post phase comments, so that should be rare. Raising the threshold later is a one-line change.
- **Recorded**: body open call struck through with the ruling, and the Proposal's `stale` line now states the 30-minute rule.
- **State**: both open calls are ruled, so the card moves from Shaping to Proposed for owner review.
