---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:49:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:49:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Merged to main as `d3d09b2`. The skills point at the board's guide and `.schema/`, and the priority and component root-key rule is gone.**

**Evidence**: `bash tests/smoke.sh; echo $?` on main at `d3d09b2` printed `smoke: 21 passed` and exit 0. The adversarial review approved in round 2. Its own runs catch all three reworded root-key mutants and leave the reserved wording alone.
**Audit**: the table is in the fixer's records on this thread, with rows added in round 2.
**Accepted limitation**: step 19 is a heuristic. It flags prose like "Priority: rank…" or "the root cause outranks priority", and its failure message says to reword the line. Any line containing "reserved" is exempt.
