# Fixer Phase 2: verification report

Sent to the lead after the gate runs in the granted slot.

```
VERIFICATION: GREEN | RED

GATE: <the exact command, as the board sheet / repo CLAUDE.md states it, and the
  gate's OWN success line with counts, e.g. "4580 passed, 0 failed, 765 skipped".>

BLAST RADIUS:
  <what actually changed, one-line rationale each, vs Phase-1 EXPECTED BLAST RADIUS.
  Name any mismatch as one.>

PREDICTION vs OUTCOME:
  <Phase-1 PRE-REGISTERED VERIFICATION vs what was measured: what held, what didn't.>

CROSS-POST:
  <2–4 lines for the related cards, posted at merge: what changed, the shape of the
  fix (type/method/seam), what a sibling fixer can REUSE or must BEWARE.>

PENDING: <anything not done, named as such, or "none". "Opening X now" inside a
  green report reads as done.>

SLOT RELEASED (worktree stays until merge)
```
