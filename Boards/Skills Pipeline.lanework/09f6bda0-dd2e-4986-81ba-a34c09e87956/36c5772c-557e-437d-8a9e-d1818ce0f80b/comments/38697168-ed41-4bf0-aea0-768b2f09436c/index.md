---
schema: 1
kind: comment
created:  {at: 2026-11-17T22:34:01Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**START: build `lint-leases.sh`, its Verified cases 1 to 7, the SKILL.md sentence and the README sizes rows.**

- **Scope**: `skills/work/scripts/lint-leases.sh` (new), `skills/work/SKILL.md`, README § Sizes, `tests/smoke.sh`. `lib.sh` untouched.
- **Verify**: cases 1 to 7 fail with the script absent, then `tests/smoke.sh` green and `tests/check-sizes.sh` clean.
- **Where**: branch `lint-leases`, the lead's worktree. No lease staked: a fixer never stakes.
