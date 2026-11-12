---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:44:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Plan: this build is claimed by the board watch and queued behind the two build-blockers.**

- **Why queued**: `tests/smoke.sh` fails on main at the guide stamp gate, and a red gate on main blocks every branch's evidence. The smoke flake card 34d09bf2 and the guide catch-up card 2c29a34f go first; both are still in Shaping.
- **Order after that**: one branch at a time where cards share `tests/smoke.sh`, `lanework/scripts/lib.sh`, `lanework/references/writes.md` or README § Sizes, each rebased on the last merge.
