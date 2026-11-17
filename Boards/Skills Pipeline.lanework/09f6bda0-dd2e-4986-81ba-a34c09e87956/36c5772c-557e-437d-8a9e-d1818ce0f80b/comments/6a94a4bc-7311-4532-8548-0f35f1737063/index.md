---
schema: 1
kind: comment
created:  {at: 2026-11-17T22:29:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: build the read-only lease lint and its seven smoke cases; the 50-card trial waits for the release.**

- **Scope**: `skills/work/scripts/lint-leases.sh` (new), one sentence in `skills/work/SKILL.md`, README § Sizes, `tests/smoke.sh`.
- **Verify**: `tests/smoke.sh` green with cases 1 to 7.
- **Where**: branch `lint-leases`, a fixer in its own worktree. No lease is staked: the released plugin this session runs has no lease script.
- **Facts that moved since the body was written, spec unchanged**:
  - `LEASE_LOST_PREFIX` is already in `lanework/scripts/lib.sh`, added by the lease script card; this card reuses it and does not touch `lib.sh`.
  - This repo's boards are under `Boards/`, not `Lanework/`; the trial command reads `Boards/*.lanework`.
  - `lease.sh` exists, so case 7 is built now.
- **After the merge**: the card stays in Active until the trial. Its done-when needs 50 leased cards, and none can be leased on a live board before the release.
- **Order**: the settings card above this one is the owner's to run.
