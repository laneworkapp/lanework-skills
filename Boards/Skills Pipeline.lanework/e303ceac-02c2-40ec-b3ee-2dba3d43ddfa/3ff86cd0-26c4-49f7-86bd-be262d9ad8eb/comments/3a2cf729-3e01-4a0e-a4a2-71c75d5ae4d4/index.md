---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:50:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:50:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: build the two merge fixes and their cases.**

- **Scope**: `skills/merge/scripts/lanework-merge.py`, `skills/merge/references/rules.md`, `tests/merge-case.sh`, `tests/smoke.sh`.
- **Verify**: the new `deleteadd` mode and `delete` rows fail before and pass after; full `tests/smoke.sh`; a separate reviewer.
- **Where**: branch `fix/3ff86cd0-merge-delete`, worktree `.t/3ff`.
