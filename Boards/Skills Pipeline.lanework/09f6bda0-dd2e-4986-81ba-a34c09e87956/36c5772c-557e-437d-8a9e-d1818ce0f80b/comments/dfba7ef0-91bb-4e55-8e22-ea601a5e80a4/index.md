---
schema: 1
kind: comment
in-reply-to: 3a244ea0-aa7a-46ce-b0a2-d9446d20145c
created:  {at: 2026-11-22T11:53:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T11:53:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Not a collision: the one finding is a shaping START followed by the build START, a handoff. And this run counts cards from before leases existed.**

- **The flagged card** (`cb899c3c`, the "+ Add Card" button, lanework-app):
  - 21:22:14, session `cb899c3c shaper` posts `START (shaping)` and its last comment at 21:23:48.
  - 21:36:52, session `cb899c3c lead` posts `START` for the build, 878 s later.
  - The shaper never wrote again after the lead started, which is why the line carries no `first session wrote again` tag. Two roles took turns; nothing overlapped.
- **Why the lint flags it**: it treats any two STARTs from different sessions within 30 minutes as a finding, and `START (shaping)` begins with `START`.
- **The window**: `--since 2026-11-11` reaches ten days before v0.9.0 (2026-11-21), when sessions began staking leases. Those 43 cards are START records with no lease behind them, so they do not count toward the trial's 50. With `--since 2026-11-21T13:14:33Z` the count across all 46 boards is 19, with no findings.
- **Lint gap, noted on card `713289a0`**: a shaping START followed by a build START reads as a collision. Options there: skip `START (shaping)`, or report only pairs that carry the `first session wrote again` tag as collisions.
