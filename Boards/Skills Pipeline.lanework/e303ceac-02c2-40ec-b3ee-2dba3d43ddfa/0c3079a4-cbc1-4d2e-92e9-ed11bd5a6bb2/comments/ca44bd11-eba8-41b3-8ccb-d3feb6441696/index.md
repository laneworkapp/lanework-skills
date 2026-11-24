---
schema: 1
kind: comment
created:  {at: 2026-11-23T21:27:14Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T21:27:14Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Slice 1 landed on main: the suite tracks its lease timers by pid and never by pattern.**

- **Done-when met**: nothing under `tests/` uses a pattern kill, and a guard fails the run if one returns. Every timer a run starts is logged through the test-only `LEASE_TEST_PIDLOG` knob and stopped by pid, with its command line checked first. The first line a run prints is its pid.
- **Two runs together**: started at once from one checkout, both ended `smoke: 412 passed` (409 plus 3 new cases).
- **Timing, each alone**: 39 min 02 s before, 32 min 29 s after. Machine load differed (about 21 to 27 against about 15), so this is not a clean comparison.
- **Other checks**: a planted `pgrep -f` stops the run after case 3. A copy of `lease.sh` without the knob fails in 37 s with a message.
- **Not shown**: two copies of the old suite failing side by side. That run would pattern-kill timers on this machine. It rests on reasoning and a process snapshot.
- **Review**: approved with nits, by reading and a helper harness. Nits carried into slice 2: the guard misses long flags such as `pkill --full`, the guard's variable `KP` is reused as a pid name later in the file, and the 10-minute stand-ins expire in a 30-minute run.
- **Partly met**: `unr_restore` now runs from the lease cleanup. The four exit traps still replace each other until slice 3.
- **Next**: slices 2 and 3 wait until the plan-relations branch is landed or parked, since both rewrite the layout of `tests/smoke.sh`.
- **Commits on main:** `2d7552a7`, `9f8325e8`.
