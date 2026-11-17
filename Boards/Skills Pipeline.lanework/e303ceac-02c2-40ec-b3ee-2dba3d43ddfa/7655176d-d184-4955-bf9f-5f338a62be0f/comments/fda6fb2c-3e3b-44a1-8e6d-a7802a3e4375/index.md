---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:31:10Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:31:10Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** Both round-1 blocking findings are fixed and measured at the new head. Notes 2, 3, 4 and 6 hold. 4 new notes, none blocking.

- **Stance**: adversarial. Trigger: the branch ships four scripts that write boards for every plugin user, and one of them commits, un-commits and pushes under a lock.
- **Round**: 2, scoped to blocking 1 and 2 plus the diff `f8ce9f7..8647cd8`.
- **Card**: [Work skill: ship move-card, post-ask and commit-board helpers](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f)
- **Branch**: `work-helpers` at `8647cd8` (`8647cd804b0156025204b12e9ef38f83f19563b2`)

**Blocking**: none.

**Notes**

1. `skills/work/scripts/commit-board.sh:151 @ 8647cd8` "`HEAD0=1   # from here the EXIT trap syncs the index to whatever HEAD is`". This is set before `git commit`, so a commit that fails still runs the trap's reset. Measured: the owner staged `s1` under the named path with `s2` in the work tree, and a `pre-commit` hook exited 1. The script exited 1 with nothing committed, and the index entry had gone back to HEAD's `a`, dropping the staged `s1`. That matches the documented success-path behaviour, which round 1 accepted, but here nothing was committed. Narrow fix: in `release`, reset only when HEAD differs from the sha read before the commit.
2. `commit-board.sh:70 @ 8647cd8` "`if [ "${#ADD[@]}" -gt 0 ] && [ -n "$HEAD0" ]; then git reset -q -- "${ADD[@]}"`". This also runs when `mine` exits because the lock was lost, so it touches the real index while another run holds the lock. That can collide on `index.lock` with the other run's `reset` or `merge`. Reasoned, not run: the lock is lost only through the reclaim race already judged microseconds wide. Guard the reset with `own`.
3. `commit-board.sh:144 @ 8647cd8` "`[ "${#ADD[@]}" -gt 0 ] || { echo "nothing to commit"; exit 0; }`". With the glob refusal gone, a glob or pathspec-magic argument naming no real file now exits 0 with "nothing to commit". Measured for `*`, `?.md`, `:/`, `:(top)top.md`, `:(glob)…`, `:!notes.txt` and `lane a/*`. Each is read literally and nothing expands, which is safe. But a caller that checks only the exit code reads it as success, and only stderr carries the "skipped" note. Exit 1 when every named path was skipped.
4. `tests/smoke.sh` case 161 (the SIGKILL leg) leaves one `work-commit.*` stage dir in `TMPDIR` per smoke run (measured: 5 before, 6 after). No hook, lock or sleeper is left: the lock from the killed run is reclaimed by case 162, and every wait sits under `perl alarm 10`, so the case cannot hang. Point the script at `TMPDIR=$T` for that leg.

**Checked**

- **Blocking 1**: OWN RUN at `8647cd8`, with the same setup as round 1 (a `pre-push` hook sleeping 5 s, the owner's unrelated `notes.txt` staged).
  - SIGTERM and SIGKILL 2 s in: HEAD holds the commit, `git status` shows only `M  notes.txt`, and the named path is clean.
  - Push rejected every time: HEAD is unchanged, the board change is unstaged (` M`) with its content in the work tree, and `notes.txt` is still staged.
  - The trap never resets before a commit has started: `HEAD0` is set only after `mine`, and the "nothing to commit" exits run before it.
  - The remaining SIGKILL window between `git commit` (or `update-ref`) returning and `sync_index` is accepted. It cannot be closed from a shell, the header names it and gives the one-line repair, and smoke case 161 now discriminates (the old script leaves `MM`).
- **Blocking 2**: with the record at `--ahead 1`, the case-157 assertion failed 8 of 8 runs with the wait removed (`post-ask.sh:72` replaced by `:`) and 0 of 8 with it intact.
- **Note 2 (glob refusal removed)**: `GIT_LITERAL_PATHSPECS=1` plus the realpath step keep every argument literal. Measured: none of the eight magic or glob forms matched anything, a real file named `*.md` committed as itself, and `lane [x]/i?.md` commits (case 164).
- **Notes 3, 4, 6**:
  - Two `--trailer` flags are kept in order as one paragraph (measured).
  - A diverged branch with no shared file prints "no file changed on both sides: rebase or merge…" and exits 1 (measured).
  - `templates/ask.md` cites `post-ask.sh`, with `writing.md` § The ask as the rule. README § Sizes `ask.md` 306 and the `work` total 7,150 are covered by `check-sizes` in smoke.
- **Lead's rulings**: notes 1 and 5 go to an Issues card, and the file-card `single` bullet is recorded as a spec gap, on the ruling comment replying to round 1.
- **Smoke**: OWN RUN at `8647cd8`, `smoke: 168 passed`. This agrees with the fixer's [record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/09f6bda0-dd2e-4986-81ba-a34c09e87956/7655176d-d184-4955-bf9f-5f338a62be0f/b3c4cfe1-c950-4c13-a077-a9642820478c).
- **Blast radius**: 4 files since `f8ce9f7` (`commit-board.sh`, `ask.md`, README, `smoke.sh`), each traced to a round-1 finding. No churn elsewhere.
