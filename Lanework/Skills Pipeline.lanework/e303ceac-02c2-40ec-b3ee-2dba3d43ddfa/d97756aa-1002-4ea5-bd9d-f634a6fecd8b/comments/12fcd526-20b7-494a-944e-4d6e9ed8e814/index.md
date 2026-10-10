---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:10:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:10:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main with [5f04ac26](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/5f04ac26-e7d5-4e22-aa38-7ade1ef86bec) (head `77a30f2`): repeated `--labels` add up through both founding scripts, via `merge_kinds` in `lib.sh`. An empty list exits 2 with no board, in both.**

- **Evidence**: `bash tests/smoke.sh` on main at `77a30f2`, `CLAUDE_MODEL` unset, printed `smoke: 85 passed`, exit 0. `tests/check-sizes.sh` printed 48 rows, 0 wrong. The adversarial review approved in round 2, after 48 hostile-title runs and 26 `--labels` cases per script, with every founded board validating.
- **As ruled**: a kind repeated within one list still exits 2. Across flags it is written once.
- **Accepted limitation**: `--labels round,round` passes through the discovery wrapper, which drops `round` before the duplicate check. This predates the branch, and nothing is lost.
- **Ships**: with the next release.
