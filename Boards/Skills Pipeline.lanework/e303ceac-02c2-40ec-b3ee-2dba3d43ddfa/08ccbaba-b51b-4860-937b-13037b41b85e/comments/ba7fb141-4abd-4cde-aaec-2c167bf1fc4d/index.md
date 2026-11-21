---
schema: 1
kind: comment
created:  {at: 2026-11-21T01:04:30Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `f8b7135` (branch `commit-board-push-reject`, head `00bb52c`, four fix rounds), pushed. Not released. This was the last card holding 0.9.0; the release is the owner's call.

**What changed in `work/scripts/commit-board.sh`**

- The owner's staged entries under the named paths are saved before the first commit. When a rejected push takes the commit back, the index is restored to exactly what was staged before the run, on every failed route: five failed pushes, a hook failing on the retry, an upstream change that stops the fast-forward. Intent-to-add entries are restored too.
- Messages say only what is true: "the index untouched" on a first-try hook failure, "restored to what was staged before the run" after an un-commit, and a "NOT restored" line with the saved file's path and the recovery commands if a restore ever fails.
- SIGTERM, SIGINT and SIGHUP are held until the running git command returns, so the cleanup can no longer race it. An interrupted run that leaves the commit on HEAD prints `interrupted: <sha> committed, not pushed` or `committed and pushed`.
- A successful commit and push is unchanged.
- `lint-ask.sh` with no arguments exits 2 with a usage line.

**Changed during review, beyond the proposal in the body**

- The exit cleanup restores only when HEAD is exactly where the script's own un-commit leaves it. The proposal's rule ("HEAD is no longer that commit") put old entries back after a good push if another commit landed on top; a reviewer measured that.
- The saved entries live in a uniquely named file in the git folder, not the stage folder, so they survive a failed restore.

**Evidence**

- `tests/smoke.sh` on `main` at `111ba99` (this merge plus two later ones): 304 passed, rc 0. An earlier run on `f8b7135` alone passed 284 cases and stopped at the plan-claim timing case, a load flake tracked in its own Issues card.
- Independent adversarial review, four rounds, approved at `00bb52c`. Ten owner states by five routes, eleven upstream cases, signals at each step, two concurrent runs: every failed route came back with `git ls-files -s` and `git status` identical to before the run. Each new smoke case fails on its mutant.
- The reproduction in the body, routes (a), (b) and (d): identical before and after.

**Known limits, stated in the script header**

- A SIGKILL between taking the commit back and the restore still loses the staged state; the saved file is left behind and the header gives the recovery commands.
- A remote with no fetch refspec makes the interrupted line say "not pushed" after a good push.

**Left open, filed as one follow-up card in Issues**: a `--push` run with nothing to commit and HEAD ahead of origin exits 0 without pushing; SIGINT to the whole process group during a pre-push hook can hang `git push`; four smaller items.

**CHANGELOG sentence for 0.9.0**: When a board commit's push is rejected, your own staged changes are now kept exactly as they were, and an interrupted commit says whether it was pushed.
