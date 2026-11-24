---
schema: 1
kind: comment
created:  {at: 2026-11-24T03:04:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-24T03:04:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: all three slices are on main. Each section of the suite runs in its own subshell.**

- **Scope**: a variable, function or trap set in one section cannot reach another. A section that assigns `PL` and `RE` for the next one to read fails on the slice 2 code and passes now. A permanent canary fails the run if scoping is ever lost.
- **Cleanup**: each section's exit trap runs when that section ends, so the traps no longer replace each other. `unr_restore` runs when its own section ends, which is before the lease section starts.
- **Stand-ins**: logged by pid and stopped after the section that started them. They now sleep 60 minutes, so none expires mid-run.
- **Failure**: the run prints each section's name to stderr and names the section a failed or killed run stopped in. A planted failure and a kill of the run each left no timer or stand-in alive.
- **Full run**: `smoke: 419 passed` in 37 min 31 s, with the case names identical and in the same order as before the slice.
- **Timing across the card**: 39 min 02 s before slice 1, 32 min 29 s after it, 37 min 31 s now. Machine load differed each time, so these do not show a speed change.
- **Review**: the first pass confirmed the scoping and asked for the section names and a narrower stand-in sweep. Both are in. The fix round was checked by the full run and by me, not by a second review pass.
- **Differs from the body**: sections run as a background subshell with a wait, so a kill of the run is taken at once. The header reads `smoke: section <name>`.
- **Not run**: two full runs together on the final code. That check passed on slice 1. `scripts/release.sh` and CI were not run. Their call is unchanged.
- **Commits on main for this slice:** `a2d05797`, `24a063a6`.
