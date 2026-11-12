---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:52:38Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:52:38Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**FAIL-BEFORE: the lint-stamps smoke cases fail on the merge-base `ed4cc29` because the script does not exist there; no other failure is possible for a new script.**

**Evidence**: scoped run of the new cases (a runner outside the repo that founds a throwaway discovery board and sources the case block) with the worktree at `ed4cc29` plus only the test block:
```
lint-stamps on a clean board: want silent exit 0, got 127:
.../skills/work/scripts/lint-stamps.sh: No such file or directory
```
**Decided**: the clean-board case checks the exit code, so a missing script cannot pass as silence.
**Verified after**: the same block passes 6 of 6 against the new script, and a planted `modified.at` in 2030 on a copy of this board is reported by file and field (the real board has no future stamp).
