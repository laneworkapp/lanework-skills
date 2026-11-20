---
schema: 1
kind: comment
created:  {at: 2026-11-20T13:42:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped and moved to Proposed, 2026-11-20. No open calls.**

- **Shaped by**: a `fixer`-tier subagent (claude-sonnet-5-5), body read by the lead before the move.
- **Measured** on a throwaway board: `move-card.sh` refuses a valid card with an iconed label kind, and one with nested JSON in its body. The other six scripts read only.
- **Approach**: one function in `lanework/scripts/lib.sh` that checks only the front matter lines a script wrote; seven scripts and `lease.sh` call it.
- **Rejected**: per-script edits; a validator-based check.
- **Stale in the old body**: three line numbers, and the lease guard is now on main, not on a branch. The reviewer's card counts were not re-measured.
- **Left out, listed in the body**: five smaller findings from the same review, each its own card if wanted.
