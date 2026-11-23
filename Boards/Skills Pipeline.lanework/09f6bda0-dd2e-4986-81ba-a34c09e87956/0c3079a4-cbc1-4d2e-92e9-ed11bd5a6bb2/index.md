---
schema: 1
kind: card
title: "The smoke suite shares variables and process patterns across sections, so new cases break it only in a full run"
order: 5120
created:  {at: 2026-11-23T12:33:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T18:47:45Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-23T19:17:43Z
---
Make `tests/smoke.sh` safe to extend: each section runs in a scope of its own, the suite handles its lease timers by pid, and one section can be run alone by name.

## Problem

`tests/smoke.sh` is 4,192 lines and about 410 cases (408 `ok` calls, one inside a 3-pass loop) in one shell. `set -euo pipefail` is its only structure. There are no section markers: a "section" is a header comment (about 66 of them, `# lanework: lease.sh.` at `:3284`, `# plan: found, file, ...` at `:695`) over a run of `ok` lines. Each of the four failed full runs on 2026-11-22 was a test fault, and three of them were a section reaching into state another section left behind.

Evidence, checked against `main` at v0.11.0:

- **Shared names.** A scan of plain statement assignments finds about 740 distinct names. About 114 are assigned in two or more headed sections, 17 in four or more (`rc` 28, `O` 14, `out` 8, `f` 8, `RC` 7, `t0` 7, `PB` 5). The two incident cases are real: `3927e45f` ("the pick-order cases no longer reuse the plan board's variable", `PL`) and `32552775` (`RE`). `RE` is still assigned a card uuid at `:509` and is only fenced by `unset RE NW` at `:3297` and a numeric check in `L` (`:3299`). The patch sits in the later section, and the earlier one is unchanged.
- **Names with two meanings today.** `LS` is the lint-stamps script at `:1149` and the lease script at `:3285`, and the pattern kills below are built on it. `D` is the discovery board (`:412`) and, in the lease section, a seconds count (`:3338`, `:3999`). `WB` is the lint-waiting-clears board (`:1353`) and the board-write helpers' board (`:2506`). The overwrite is harmless today only because nothing reads `D` after `:3338`.
- **Fixtures are shared on purpose, and by name.** The discovery board `D` is read by 16 later sections, the pipeline board `P` by 5 (`:1634`, `:1946`, `:2506`, `:3050`, `:3284`), the plan board `PL` by 2, the lease board `LB` by 3 (`:3768`, `:3937`, `:3979`). Four sections copy `D`: two strip its cards (`:1208`, `:1352`) and two read the first card it holds (`:1149`, `:1570`), so they need a founded board with a card or two, not the chain's end state.
- **Shared files too.** 15 fixed file names under `$T` are used by two or more sections (`err.txt` by 9, `fc.md` 6, `r1.md` 4, `t.md` 4, `pc.md` 4). A scope for variables does not scope these.
- **Exit traps replace each other.** `:699`, `:1447`, `:3293` and `:3626` each set `trap ... EXIT`; only the last one runs. `lease_cleanup` (`:3288`) does not call `unr_restore` (`:1446`), so the permission restore from the lint-unreadable cases is dropped for the rest of the run.
- **Pattern kills and waits, five sites.** `pkill -f "$LS _timer"` in `lease_cleanup` (`:3290`), and `pgrep -f` at `:3375` (case 3b), `:4020` (plan claim TERM), `:4142` (plan leave-nothing) and `:4149` (case 13, `pgrep -f "$LS _timer"` for every timer of this checkout, from any run). `$LS` is a path in the checkout, so two runs from one checkout kill each other's timers and stall each other's case 13. `skills/work/references/traps.md:18` already says why `pgrep -f` is wrong. `pkill -P "$WP"` (`:1640`, `:1652`) kills a pid's children and is not a pattern kill. `tests/merge-case.sh` and the two check scripts have no kills.
- **The pid is already on disk.** `lease.sh` saves `pid=<timer>` in its memory file `$TMPDIR/lanework-lease/<session>/<board key>/<card>` right after `nohup ... &` (`ensure_timer`, `lease.sh:206-207`), and smoke reads it as `mpid` (`:3325`) and `pmpid` (`:3988`). The memory file is removed on release, so a check made after a release (the 3b, P2b and case 13 assertions) has no pid left to read. The timer is an orphan of a `lease.sh` that has exited, so a test cannot find it by parent either.
- **No way to run one section.** Nothing names a section; `tests/merge-case.sh <dir> <mode>` is the only part of the suite with a run-alone form.

Two points in the founding note need care. It gives a complete run as "30 to 60 minutes": that is what the full runs took on 2026-11-22 and 2026-11-23 with several sessions working on the same machine. Earlier records on the board show `smoke: 248 passed` in 4 min 59 s, which scales to roughly 8 to 10 minutes at 410 cases, and the literal waits in the script total a few minutes. Whether the rest is machine load or the pattern waits below stalling is unmeasured; slice 1 times the run before and after. Second, `pkill -f "bash tests/smoke.sh"` appears nowhere in the repo: it was an agent's command and cannot be fixed in a file. What can be fixed is that the suite gives its own pid on its first line.

## Proposed change

Three slices. 1 and 2 stand on their own; 3 rides on slice 2's named sections.

### Slice 1: timers by pid (done-when 2)

- `lease.sh` gets one more test-only knob, `LEASE_TEST_PIDLOG=<file>`: `ensure_timer` appends `$!` to it. It sits beside the five existing `LEASE_TEST_*` knobs and is listed in the header with them. Nothing changes without the variable.
- Smoke exports one pid log per run (`$T/timers.pids`) before the first lease case. Every timer any wrapper starts is logged, whatever its TMPDIR (`L`, `LW`, `LN`, `LRP`, `LWP`, `LX`, `L1`, `PLS`, `PE`, `LLL`).
- `timer_alive <pid>` is `ps -ww -p <pid> -o command=` containing `lease.sh _timer`, so a reused pid is never taken for a timer (the check `is_timer` makes at `lease.sh:199`). `timers_left` lists logged pids that pass it. `lease_cleanup` kills exactly those and the stand-ins in `LSP` and `PSP`, and nothing else.
- Replace the five pattern sites: `:3375` and `:4020` wait on the pids that case logged (a count taken before and after), `:4142` and `:4149` wait for `timers_left` to be empty. A wait that cannot finish prints the pids and their command lines.
- A guard in smoke, shaped like the early-reader guard at `:58`, fails when anything under `tests/` contains `pkill -f`, `pgrep -f` or `killall`. `pkill -P` stays allowed. It carries a self-check sample.
- The first line smoke prints (to stderr, so `release.sh`'s `>/dev/null` hides nothing it needs) is `smoke: pid <n>, scratch <dir>`. A run is stopped with `kill <n>`.

### Slice 2: named sections, run alone (done-when 3)

- Each of the about 28 headed groups becomes a function `sec_<name>` and a row in one list at the end of the file: static checks, founding, heal-board, discovery, plan, usage and braces, lint-ask, lint-stamps, lint-leases, lint-waiting-clears, lint symlinks, post-comment, watch, arm-pass and pick order, merge, lane actors and heal-descriptors, label kinds, versions and controls, filing defaults, board-write helpers, commit-board, release gate, cite-as, heal-descriptors, lease, card-writers on the lease board, plan lease, usage guard and plugin. The lease group stays whole, because its helpers (`L`, `lcard`, `mpid`) and its board `LB` are shared by four sub-sections on purpose. The proposed names and line ranges are a first cut; the build confirms them against the headers.
- `tests/smoke.sh --list` prints the names. `tests/smoke.sh --only name[,name]` runs those sections, in file order, after the shared prelude (`:1-80`: `T`, `SK`, `VAL`, `ok`, `validate`, the helpers). The existing optional `<scratch dir>` argument keeps working, and so do the argument-less calls from `.github/workflows/smoke.yml` and `scripts/release.sh:41` (`tests/smoke.sh >/dev/null`).
- A section that needs another section's board says so with one line, `needs fixture_discovery`, where each fixture is a function that founds that board fresh under `$T`. The four sections that copy `D` take the fresh board; the fixture files the one or two cards they read. The discovery chain (`:408-694`: `D` and `C1..C5` are built up case by case) is one section, so what follows it never needs its cards.
- With `--only`, the run ends `smoke: <n> passed (sections: a, b)`, so a partial run cannot be mistaken for a full one. The unqualified run keeps `smoke: <n> passed` as its last line.

### Slice 3: each section in its own subshell (done-when 1)

Owner ruled A, 2026-11-23: each section is a function run in its own subshell.

- The runner calls each section as a plain statement, `( sec_<name> )`, never through `||` or `if`, which would switch `set -e` off inside it. It prints a `section: <name>` header first, and a top-level exit trap names the section a failed run stopped in.
- `ok` keeps its count in a file under `$T`, since an increment inside a subshell is lost. The last line and the exit code are unchanged.
- Each section sets its own exit trap, which runs when its subshell ends. The four `trap ... EXIT` lines stop replacing each other, and `unr_restore` runs again.
- The boards shared on purpose (`D`, `P`, `PL`, `LB`) reach a section only through its `needs fixture_<name>` line from slice 2. Nothing else crosses a section boundary.
- With `set -u` already on, a section that reads a name another section set fails at once.

## Out of scope

- Splitting `tests/smoke.sh` into several files. The run-alone form makes it unnecessary, and a split would change what `release.sh` and CI call.
- Speeding up the suite. Section names make a timing table possible, and that table is not part of this card.
- Moving the fixed file names under `$T` into per-section folders. Slice 3 notes the 15 shared names; it only fixes one that the build finds biting.
- Any change to what a case asserts.

## Risks

- **A knob in a shipped script.** `LEASE_TEST_PIDLOG` is a few lines in `lease.sh` that nothing reads outside tests. It is not user-facing: no CHANGELOG entry, and `tests/check-sizes.sh` counts only the `.md` files.
- **Moving every case into a function can change what a case sees**: a trailing `set -e` call context, `$?` at the end of a line, `local`. Slice 2 keeps the sections as plain calls and checks that the unchanged ones still pass; a hand-edit of bodies is avoided on purpose.
- **A section run alone can pass for the wrong reason** if a fixture it needs is missing and an `${X:-}` default hides it. `needs` lines make this visible, and slice 3's check below reads each section alone.
- **Pid log gaps.** A timer started in a process that does not inherit the export (the commit-board hooks, `env -i` calls) goes unlogged. None of the lease wrappers does; the check at the end of slice 1 is one case that starts a timer through each wrapper and sees every pid logged.

## Verification

Each slice ends with one full `tests/smoke.sh` run, never against `Boards/`.

- **Slice 1**: the guard fails on a planted `pgrep -f` (a self-check). Two runs of the suite from one checkout, started together, both end `smoke: N passed` (the case that fails today); a throwaway copy of `lease.sh` without the knob makes the pid log empty and the run fail loudly, not silently pass. Time the full run before and after, on the same machine, and quote both in the closing record.
- **Slice 2**: `--list` names every section once; `--only` of each section on its own passes or names the fixture it lacks; the sum of the sections' case counts equals the full run's count (`ok` is 410 today).
- **Slice 3**: a throwaway case that assigns `PL` and `RE` in one section and reads them in the next fails the run and passes after the fix.
- `bash -n tests/smoke.sh`, `tests/check-refs.sh` and `tests/check-sizes.sh` stay green. CI (`.github/workflows/smoke.yml`) needs no edit.

## Done when

- [ ] Nothing under `tests/` uses `pkill -f`, `pgrep -f` or `killall`, and a guard in smoke fails if one comes back.
- [ ] Every timer a smoke run starts is stopped and waited on by its logged pid, with the process's command line checked first; two simultaneous runs from one checkout both pass.
- [ ] The suite's first line gives its pid.
- [ ] `tests/smoke.sh --list` names every section and `--only <name>` runs one; a partial run says so on its last line; the full run's output, exit code and case count are unchanged.
- [ ] A section cannot read a variable another section assigned by accident: a throwaway case that does so fails the run before the fix and passes after it, with each section in its own subshell.
- [ ] The exit traps no longer replace each other: a section's cleanup runs when it ends, and `unr_restore` still runs after the lease section starts.
- [ ] `tests/smoke.sh` passes in full, and a timing before and after is in the closing record.

## Recommendation

Approve all three slices. Build slice 1 first: it needs no ruling and removes the timer stalls that cost the most. Slice 2 follows. Slice 3 then adds only the `( ... )` call around each section and the counter file for `ok`, and moves the shared fixtures into `needs` lines.
