---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:52:12Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:52:12Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**FAIL-BEFORE: the new smoke cases fail on the unchanged skills at 35ba2ce, on the card's own observable.**

- **Evidence**: `tests/smoke.sh` with the new block, run from the worktree before any skill edit. Cases 1-38 pass, then the first new assertion stops the run: `lane body missing or one sentence: .../design-loop.lanework/<lane>/index.md`. A design-loop lane body names no actor or trigger, which is the card's stall.
- **Evidence**: the assertions behind it fail for the same reason and are unreached until it passes: Tasks and Approved say nothing of "without waiting to be asked" in Tasks, no `| lane | who acts |` table exists, `events.md` item 6 still says "a move", the `watch` description still says "requested", and `skills/heal/scripts/heal-descriptors.py` does not exist, so the dry-run, apply and idempotence cases cannot run.
- **Accepted limitation**: the heal cases fail on a missing script, not a wrong output: the script is new in this card.
