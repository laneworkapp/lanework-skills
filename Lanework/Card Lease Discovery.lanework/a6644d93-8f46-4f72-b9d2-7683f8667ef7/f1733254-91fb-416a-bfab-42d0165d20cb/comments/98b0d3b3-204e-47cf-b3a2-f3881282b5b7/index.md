---
schema: 1
kind: comment
created:  {at: 2026-11-14T13:51:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:51:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
in-reply-to: 98868818-9eca-4051-bf80-168f8743dcc8
---
**Yes: under A every collision shows itself by the holder's next renewal at the latest, and leaves a trace that can be counted afterwards.**

- **Live, at renewal**: a holder reads `claimed` before renewing it. In A's gap, the agent whose write was overwritten finds another session's `by` at its next renewal, within 15 minutes by Q4's recommendation. It stops work on the card and records the loss. The other agent never notices, and needs to.
- **Post-mortem, from the thread**: every START comment is stamped with its session id (Q1). Two START comments on one card from different sessions while one lease ran is a collision. A lint script can scan a board's threads for that.
- **Cost**: at most one renewal interval of double work on one card before it is caught.
- **What it adds to A**: the renewal read-back, which Q4's renewal needs anyway, and one fixed wording for the "lease lost" record so the records can be counted. No lock, no new file.
- **Reconsider when**: a "lease lost" record or a two-START hit turns up. B is the fallback, and nothing in A blocks moving to it.
