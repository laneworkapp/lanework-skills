---
schema: 1
kind: comment
created:  {at: 2026-10-25T16:21:12Z, by: {name: shaper, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T16:21:12Z, by: {name: shaper, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Shaped into a proposal: one new script classes the arming pass, two owner calls remain.**

- **Decided**: the script reads files only (`in-reply-to`, `created.by`, START comments), so the router never opens a card. A card with an unanswered owner comment and an unclaimed agent-lane card gets one line, `comment` winning.
- **Rejected**: extending `read-board.sh`. It is the `lanework` skill's and prints titles only, so the dispatch-specific classing belongs in `dispatch/scripts`.
- **Rejected**: auto-releasing stale claims. The card already rules flag-only.
- **Open**: the stale-claim rule and the sweep scope, asked next. The card stays in Shaping until both are ruled.
