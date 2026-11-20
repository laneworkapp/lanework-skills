---
schema: 1
kind: comment
created:  {at: 2026-11-20T13:42:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped and moved to Proposed, 2026-11-20. No open calls.**

- **Shaped by**: a `fixer`-tier subagent (claude-sonnet-5-5), body read by the lead before the move.
- **Measured** on a throwaway board and a symlink to it. The unreadable case is wider than filed: `lint-stamps.sh` and `lint-waiting-clears.sh` have it too, not only `lint-leases.sh`. The symlink case is `lint-stamps.sh` alone; `lint-leases.sh` already follows one on main.
- **Approach**: one helper in `lanework/scripts/lib.sh` lists a board's files and reports what it could not read; the three lints use it and exit 2 on any unread part, findings still printed.
- **Rejected**: resolving the path in `lint-stamps.sh` (changes the printed spelling); fixing each script inline.
- **Decided without asking**: exit 2 for an unread part. Strike or change at review.
