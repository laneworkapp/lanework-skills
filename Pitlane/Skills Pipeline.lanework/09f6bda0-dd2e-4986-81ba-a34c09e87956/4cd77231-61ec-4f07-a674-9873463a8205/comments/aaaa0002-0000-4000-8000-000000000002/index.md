---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:10:02Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T23:10:02Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and verified: `tests/smoke.sh` step now accepts only the known CLAUDE.md warning.**

**Gate**: `bash tests/smoke.sh; echo $?` in the worktree printed `smoke: 20 passed`, exit 0.
**Warning-only negative**: temp copy of the repo with `bogusfield` added to `plugin.json` makes the CLI print "bogusfield: Unknown field" as a warning, exit 0 non-strict. Smoke on the copy exits 1 with "plugin validate: unexpected warning".
**Error negative**: same copy with `author` set to a string. The CLI exits 1 ("Validation failed"). Smoke exits 1 with "plugin validate failed".
