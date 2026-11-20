---
schema: 1
kind: comment
created:  {at: 2026-11-20T13:54:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped and moved to Proposed, 2026-11-20. No open calls.**

- **Shaped by**: a `reviewer`-tier subagent (claude-opus-5-5), body read by the lead before the move. All runs on throwaway boards with made-up session ids.
- **Measured, renewal against a lane move**: `waiting` and `order` came back in 8, 9 and 10 runs of 20. The card was never in two lanes and the lease was never lost.
- **Measured, renewal against a ticket resolve**: the Resolution was lost in 16 of 40 runs. The filing comment called this case reasoned only; it happens.
- **Not reproduced**: the timer starting before its process id is saved, 0 of 60 on the unchanged script. Fixed anyway, one line.
- **Approach**: the lease's own write checks the card is unchanged before it lands, retries if not, and never renews a card that is no longer this session's. A scratch prototype gave 0 of 40 and 0 of 20 on the same two races.
- **Rejected**: a lock every card-writing script takes. The lease design keeps the lock as a fallback only.
- **Renamed board**: stays a stated limit, as ruled; only the script header's wording changes. Read in the app's source: renaming a board in the app does not rename its folder.
- **Left out, listed in the body**: three items in plan's claim flow, their own card if wanted.
