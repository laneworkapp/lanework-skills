---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:29:03Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:29:03Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Built on `waiting-clears` at `0d6d5a6`: `tests/smoke.sh` green, `smoke: 183 passed` (174 on main plus 9 new cases).**

- **FAIL-BEFORE**: the new case run at the merge-base source stopped at it with `lint-waiting-clears.sh: No such file or directory` (exit 127). A new script has no weaker observable than its absence, so the reviewer may mark this REASONED.
- **Evidence**: `tests/smoke.sh` in the worktree, foreground, exit 0; `tests/check-sizes.sh` 57 rows, 0 wrong; `tests/check-refs.sh` 225 references, 0 missing. The nine cases, 72 to 80, cover every bullet under the body's "Verified by", and the tree is checksummed before and after a run (byte-identical).
- **Decided**: the README § Sizes rows for `writing.md`, `events.md` and `SKILL.md` moved, with their skill totals, because those files changed (body expected no move).
- **Accepted limitation**: an ask here is any agent comment whose first non-blank line starts with `@`; `lint-ask.sh` needs the board's human handle and checks the shape. The two differ on a handle that is neither.
- **Not done, by design**: no CHANGELOG entry, no clearing helper, `move-card.sh` and `post-ask.sh` untouched, `plugin.json` unbumped.
