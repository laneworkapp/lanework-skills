---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:57:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:57:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Merged to main as `fec08f4`. The stamp lives once in the repo's `CLAUDE.md` at guide v82 and schema v1, and smoke gates it.**

**Evidence**: `bash tests/smoke.sh; echo $?` on main at `fec08f4` printed `smoke: 22 passed` and exit 0. The adversarial review approved in round 1. Its own mutants showed the gate fails closed on v100, on v8 against v82, and on a missing board or an empty VERSION.
**After the review**: three of its notes were applied in `dfbfd50`. The stamp check is case-insensitive and covers the schema stamp, the schema parse is anchored, and the README names this repo's board. The lead checked that diff, and smoke was re-run on the merged head.
**Filed**: the README word-count drift, which predates this change, is its own card in Ideas.
