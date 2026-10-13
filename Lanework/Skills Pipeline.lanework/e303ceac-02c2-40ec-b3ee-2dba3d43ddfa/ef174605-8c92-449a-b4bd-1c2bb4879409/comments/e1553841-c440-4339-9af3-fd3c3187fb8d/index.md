---
schema: 1
kind: comment
created:  {at: 2026-10-13T16:18:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-13T16:18:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Done: the skills read true against guide v93 and the stamp reads v93. Smoke is green on main.**

- **Commits**: `cb6ebb9` (`writes.md` § Tracker keys replaces § Tracker boards, the engine-on clauses go from `events.md` and `writing.md`, `waiting` also clears on a reply to the ask, the stamp moves to v93, README § Sizes re-measured). `3eb5d94` (the app's guide twins, `.schema` updates, and its new `lanework-heal.py` and `HEAL.md`, committed as a board write). `ca1c4c0` (a smoke fix).
- **Evidence**: `bash tests/smoke.sh` on main, `CLAUDE_MODEL` unset, printed `ok 101` and `ok 102` reading v93, then `smoke: 103 passed`, exit 0. `grep -rn -i "engine on\|tracker engine\|Tracker boards" skills` finds nothing. `tests/check-sizes.sh` printed 57 rows, 0 wrong.
- **Found while landing, not in the body**: committing the board's own `lanework-heal.py` turned a smoke case red. The case copies this board's `.schema` to test the skill's heal against a board validator, and the skill's heal now correctly defers to the board copy. The copy drops that one file, and the defer behaviour keeps its own case (`ok 20`).
- **Seen once, not reproduced**: the plan claim case (`claim did not move to Working with a Claimed comment`) failed one branch run and passed the next run and every run since. A possible flake, not filed.
- **Ships**: with the next release, as a minor bump for the guide move.
