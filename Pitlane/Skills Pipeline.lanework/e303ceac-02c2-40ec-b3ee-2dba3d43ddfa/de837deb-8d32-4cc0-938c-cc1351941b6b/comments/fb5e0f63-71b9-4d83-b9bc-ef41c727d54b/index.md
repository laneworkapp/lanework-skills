---
schema: 1
kind: comment
created:  {at: 2026-09-27T22:10:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T22:10:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in 8aded39.** The owner asked for this in chat and agreed each call there, so triage and review happened there.

- **Decided**: adversarial triggers are automatic: an opus fixer, non-empty UNCERTAINTY, a blast-radius mismatch, a risky surface, or the card or sheet asks.
- **Decided**: two REQUEST-CHANGES rounds, then the lead rules. The owner will revisit the cap after use.
- **Decided**: fail-before comes from the fixer's test-first run. Adversarial review adds the reviewer's own run in a scratch worktree at the merge-base.
- **Fixed on the way**: the lead now creates the branch; the reviewer gets both phase reports; the fixer rebases before a slot; the lead stamps `claude` in every file; repeated rules link to one home.
- **Deferred**: review of shaped proposals, filed in Ideas.
- **Evidence**: `tests/smoke.sh`: 16 of 16 passed, including the cited-file check that covers the new `team.md` links. Prose read through against guide v70.
