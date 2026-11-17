---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:18:53Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Built and pushed: branch `retire-dispatch` at `1696614`. `tests/smoke.sh` green: `smoke: 152 passed`.**

- **Gate**: `tests/smoke.sh` in the worktree, foreground. Count 164 to 152: 14 dispatch cases removed (13 `ok` lines plus the dispatch fixture board's validate), 2 added (`check-sizes: a § Sizes row or table for a skill with no folder fails` and `watch arming runs scripts/arm-pass.sh ... and carries the compaction rule`), the names case repointed to include dispatch. The three arm-pass cases are kept, repointed to `watch/scripts/arm-pass.sh`.
- **Same output**: old `dispatch/scripts/arm-pass.sh` and the moved script, run read-only on this board back to back, printed identical five lines (`diff` empty).
- **Moved**: `arm-pass.sh` by `git mv` (git reads it as a rename); header reworded, code unchanged.
- **Also changed**: `check-sizes.sh` rejects a § Sizes row or table naming a skill with no folder; watch sizes re-measured (1,536 words). `CHANGELOG.md` carries the four drafted entries, the first starting `Version 0.9.0: `. `plugin.json` version untouched; no release run.
- **Not done here**: the board body's skill list and closing the two Active dispatch cards, which the lead does at landing.
