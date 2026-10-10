---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:40:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T11:40:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Done: the stamp reads `lanework-agent-guide v84` (`42107c6`), and the app's v84 guide twins are committed with this card. Smoke is green on main.**

- **Evidence**: `bash tests/smoke.sh` on main at `42107c6`, `CLAUDE_MODEL` unset, over the landed lane-icons change `d3ad138`, printed `ok 78` and `ok 79`, both reading v84, then `smoke: 80 passed`, exit 0.
- **Taken out of queue order**: it was fourth in Approved, but a red gate on main blocks every other card's evidence, so it went first.
- **Drift**: none. The re-check matched the shaping one: no skill text names the Group By menu or `by: priority`.
