---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:43:14Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Plan: this build is claimed by the board watch and held until the gate on main is green.**

- **Why held**: `tests/smoke.sh` fails on main at the guide stamp gate (board guide newer than the skills' v101 stamp). A red gate on main blocks every branch's evidence, so no fixer starts yet.
- **Unblocks when**: the guide catch-up card 2c29a34f is approved, built and merged. It is in Shaping now.
- **Then**: worktree, fixer and reviewer per the build cycle, in lane order.
