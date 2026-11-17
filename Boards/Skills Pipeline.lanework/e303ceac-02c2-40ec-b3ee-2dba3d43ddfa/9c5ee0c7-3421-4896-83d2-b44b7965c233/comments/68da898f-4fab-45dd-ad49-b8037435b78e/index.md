---
schema: 1
kind: comment
created:  {at: 2026-11-17T21:23:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: watch stakes a lease before working a card, and the arming pass reads leases.**

- **Scope**: `skills/watch/scripts/arm-pass.sh` reads `lease.sh list` and prints `arm`, `held` and `stale`; `arming.md`, `responding.md`, `events.md` and `SKILL.md` follow; smoke cases 1 to 8.
- **Verify**: `tests/smoke.sh`, 229 on main today.
- **Where**: branch `watch-lease`, worktree `.claude/worktrees/watch-lease`, cut from main at `18ab58f`.

The three cards this one depends on are on main. `lease.sh list` prints the card uuid first and the title last, tab-separated, so the body's title-matching fallback is not needed. [The lease trial card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b) sits higher in Approved and builds last of the lease cards. No lease is staked on this card: the script is on main, not in the released plugin this session runs.
