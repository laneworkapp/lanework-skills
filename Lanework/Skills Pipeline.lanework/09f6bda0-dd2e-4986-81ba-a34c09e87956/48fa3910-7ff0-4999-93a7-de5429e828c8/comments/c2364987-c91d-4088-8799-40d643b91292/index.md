---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:44:11Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:44:11Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**FAIL-BEFORE: the new smoke cases fail at the merge-base bca7ced, with the card's observable.**

- **Command**: `env -u CLAUDE_MODEL bash tests/smoke.sh` in the worktree, new cases added, watch-boards.sh unchanged.
- **Result**: exit 1 after ok 38; the first new case fails: `no skills fingerprint stored:` / `watch-boards.sh: not a board: .../skills-copy` (`--skills` is taken as the state file).
- **Raw run**: tail below.

```
ok 37 - watch-boards refuses two boards with one folder name
ok 38 - watch-boards: without --skills there is no skills state and no behavior change
no skills fingerprint stored:
watch-boards.sh: not a board: <tmp>/lanework-smoke.cBr9mi/skills-copy
```
