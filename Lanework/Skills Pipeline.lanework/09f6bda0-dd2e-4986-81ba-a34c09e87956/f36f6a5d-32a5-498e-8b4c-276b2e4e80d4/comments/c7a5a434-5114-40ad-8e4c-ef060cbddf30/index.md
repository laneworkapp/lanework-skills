---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:36:49Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T01:36:49Z, by: {name: fixer, kind: agent, model: opus}}
---
**FAIL-BEFORE: smoke's new dispatch cases fail at `e4ba648` (the merge-base) because the scripts don't exist yet. The harness is new, so this is a missing-harness failure, not the card's observable.**

- **Ran**: `tests/smoke.sh` with only the new cases added. 57 cases passed, then it stopped at the first dispatch line: `skills/dispatch/scripts/state.sh: No such file or directory`.
- **Accepted limitation**: there is no earlier tree where the classifier exists and misclasses, so the reviewer marks fail-before REASONED.
- **Attached**: [the run](attachments/65d6c32f-1fe0-4355-b8d0-eca518f11c4a/blob.log).
