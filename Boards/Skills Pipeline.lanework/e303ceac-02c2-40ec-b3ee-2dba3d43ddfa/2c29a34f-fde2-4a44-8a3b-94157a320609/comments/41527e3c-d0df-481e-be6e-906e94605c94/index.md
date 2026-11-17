---
schema: 1
kind: comment
created: {at: 2026-11-12T00:48:40Z, by: {name: shaper, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Re-scoped to v114 and retitled. The body maps eight guide changes to skill files or to nothing.**

**Decided**: the stamp target is v114, the board's guide now. The schema stamp stays v1. Labels are now lanework, work, merge and heal. Discovery and plan drop: their scripts already handle a list-form `waiting` and need only smoke cases. `heal-board.py` gets the four drifts heal v5 fixed (component, `board`, relations walk), not a re-base.
**Rejected**: making the discovery and plan scripts parse `waiting.for`. None reads `for`: they drop or test the whole line.
**Accepted limitation**: `card-title-edit` fixtures stay. No app retitle has landed since `9a12b5d`.
**Evidence**: `git diff HEAD` of the guide (v101 to v114) and of `.schema/`, split at v107 by Board Runner Discovery's guide. `tests/smoke.sh` on `main`: 123 checks ok, then fails at the stamp gate only (board guide v114, stamp v101).
