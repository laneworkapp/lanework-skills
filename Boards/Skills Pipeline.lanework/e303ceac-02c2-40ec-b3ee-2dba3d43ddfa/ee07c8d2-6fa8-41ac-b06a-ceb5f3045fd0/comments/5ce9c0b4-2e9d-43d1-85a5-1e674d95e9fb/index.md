---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:39:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: the dispatch skill is removed on main, and watch carries the arming sweep and a compaction rule. Not released: 0.9.0 is the owner's to cut.**

- **Merge**: `a0d281c` on main, from branch `retire-dispatch` at `3234976` (three commits).
- **Gate**: `tests/smoke.sh` on merged main printed `smoke: 152 passed`, exit 0. Before: 164. Removed 14 dispatch cases, added 2.
- **Review**: adversarial, two rounds of request-changes, then approve at `3234976` after one lead-ruled fix.
  - Found: the arming table answered an owner comment and stopped, so an approved card with a note on it was never built. Fixed for both the answered-now and the already-answered case.
- **Done-when**:
  - `skills/dispatch/` gone; `arm-pass.sh` at `skills/watch/scripts/` with code unchanged and identical output on this board. Met.
  - `arming.md` has § Arming pass and the compaction rule. Met, and smoke pins both.
  - `plugin.json` skills list, README table, install commands and § Sizes name seven skills. Met. `check-sizes.sh` now fails a sizes row for a skill with no folder.
  - CHANGELOG entry starting `Version 0.9.0: `. Met. `plugin.json` still reads 0.8.0 until the release script runs.
- **Rulings carried out**: A1 (landed before the lease card). B1 (f36f6a5d and 4ada828e closed as withdrawn, `4e41cea`). C2 (0.9.0 in the changelog).
- **Board**: the board body's skill list drops `dispatch` (`c7fc806`). The `Skill` label has no value list in the board config, so nothing is removed there. Closed cards keep their `dispatch` label.
- **For the release**: 0.9.0's notes will also carry the guide v118 entries, as `release.sh` collects every changelog line since `v0.8.0`.
- **Notes posted on**: 36c5772c, eb4a1000, 4596a2cb, 714177b9, 9c5ee0c7, 42019d3d, 0f83a9dd.
