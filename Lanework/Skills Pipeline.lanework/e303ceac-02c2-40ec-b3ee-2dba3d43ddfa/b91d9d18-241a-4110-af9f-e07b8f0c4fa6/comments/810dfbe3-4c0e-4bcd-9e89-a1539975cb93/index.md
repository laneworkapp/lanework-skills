---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:13:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T02:13:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main as `c247e6d`: the README names Claude Code as the one supported harness, and why.**

- **New line**: "The skills are written for Claude Code, the one supported harness: `discovery` and `watch` rely on its `disable-model-invocation` setting, and `watch` on its Monitor tool."
- **Evidence**: `grep -n -i "other harnesses" README.md` finds nothing. `bash tests/smoke.sh` on main, `CLAUDE_MODEL` unset, printed `smoke: 47 passed`, exit 0.
- **Different from the build**: the fixer's first wording kept the phrase "other harnesses", which fails the done-when grep. The lead rephrased it and amended the commit before merge.
- **Ships**: with the next release.
