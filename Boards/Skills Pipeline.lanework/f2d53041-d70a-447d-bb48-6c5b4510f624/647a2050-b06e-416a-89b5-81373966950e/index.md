---
schema: 1
kind: card
title: "commit-board.sh: a --push retry that does not push, a push that can hang, and five smaller leftovers"
order: 10240
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T01:04:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T13:20:11Z}
---
`commit-board.sh --push` now pushes a commit that an earlier interrupted run left unpushed, a push that never returns ends within a bound with the cleanup run, and the script's closing and interrupted lines stop naming the wrong commit.

## Problem

All measured on throwaway repos with a bare origin, on `main` as of v0.9.0.

- **A retry that does not push.** A run killed with SIGKILL while a pre-push hook slept left `HEAD` one commit ahead of `origin/main`. A second `commit-board.sh --push "m" B/c` printed `nothing to commit` and exited 0, and origin still lacked the commit. Cause: `skills/work/scripts/commit-board.sh:212` exits 0 on an empty `STAGED` before any push.
- **A hang.** Not reproduced (a SIGINT to a process group around `git push` deadlocks, so it was not run): reasoned from `commit-board.sh:221`, where `git push` runs in the foreground with no bound, and from the header, which says a hung push holds SIGTERM and SIGHUP until it returns. A pre-push hook that sleeps 4 s kept the script in the push for the full 4 s. There is no `timeout` on macOS, so the bound needs a small wrapper.
- **SIGINT to the script alone is dropped while a git child runs.** Not a defect: `commit-board.sh:29-33` already states it, and Ctrl-C reaches the whole group, which works. Dropped from the card.
- **`push.err` cannot be written.** Reproduced with a pre-commit hook that runs `chmod a-w` on the run's stage folder. Output: `line 221: .../push.err: Permission denied`, then `push rejected (try 1 of 5); un-committing`, then `sed: .../push.err: No such file or directory`, then `interrupted: 9918970d committed, not pushed`, exit 1. `git log` showed the commit still on `HEAD` and `status` showed ahead 1. The failed redirect makes the `if` false, and `sed` then fails under `set -e` before `update-ref` at line 225. The "interrupted" wording is also wrong, since no signal was involved.
- **A SIGKILL leaves the saved-entries file.** Reproduced: after the SIGKILL run above, `.git/lanework-commit-board.saved.HxYvJA` remained and the next run did not remove it. The header documents it as the recovery source after a kill, so deleting it blindly would lose that recovery.
- **The closing `git log -1` after an owner reset.** Reproduced: a pre-push hook moved `main` back to the owner's commit during a good push. The script exited 0 and printed `HEAD reset to 44cd4b4f ... after 0104bf1d was pushed`, then the closing line `44cd4b4 owner`, the owner's commit, as if it were the run's. Cause: line 233 logs `HEAD`, not `$NEW`.
- **No fetch refspec, or a push mapped to another branch.** Reproduced the precondition: with `remote.origin.push = refs/heads/main:refs/heads/other`, a good push left `origin/main` unchanged while the commit landed on `other`. The interrupted line (`commit-board.sh:100-102`) checks only `refs/remotes/origin/<branch>`, so a signal after such a good push would say "not pushed". The wrong line itself was not run, as it needs a signal in a one-instruction window: reasoned from those lines.

## Change

All in `skills/work/scripts/commit-board.sh`, with its header comment kept in step (the header is the one place the behavior is stated).

- **Retry pushes.** At the `nothing to commit` branch (line 212), when `--push` is given, `origin/<branch>` exists and `HEAD` is ahead of it (`git rev-list --count "$UP..HEAD"` above 0), push instead of exiting. On success print the one-line log of `HEAD` and exit 0. On a rejected push, `continue` the loop after the existing `sleep 1` (nothing of ours is on `HEAD`, so there is nothing to un-commit; `sync` fast-forwards or stops on a diverged branch as it does now). If the tries run out, exit 1 with the existing "push failed 5 times" line naming the unpushed commit. Without `--push`, or with no tracking ref, behavior is unchanged. Header: update the "nothing to commit" sentence.
- **Push bound.** Run every `git push` through one function `push_bounded` that starts `git push` in its own process group via a small `perl` wrapper (setpgrp, fork, alarm), kills the group on expiry, and returns 124. The limit is `LANEWORK_PUSH_TIMEOUT` seconds, default 120. On a timeout, do not un-commit and do not retry: a push that hung may have landed, so keep the commit on `HEAD`, let the normal cleanup run, print `push timed out after N s; <sha> committed, not confirmed pushed; run --push again`, and exit 1. The next run then pushes it through the retry fix above. Header: replace the sentence about a hung push holding signals.
- **Unwritable `push.err`.** Run the push so that a failed redirect is still a push failure that reports `git push output unavailable`, and make the `sed` of `push.err` non-fatal (`|| true`) so `update-ref` always runs. Make the stage-folder `rm` in `release` non-fatal too, so the lock is always removed first and the cleanup never stops early.
- **Saved-entries file.** Name it `lanework-commit-board.saved.<pid>.XXXXXX`, and under the lock, before the first commit, remove such files whose pid fails `kill -0` and that are older than one day (`find ... -mtime +1`). A fresh dead-pid file is kept, so the recovery steps in the header still work for a day. Header: say so.
- **Closing line.** After a good push print `git log --oneline -1 "$NEW"` when the run committed, so an owner reset cannot change it.
- **Interrupted line.** When `origin/<branch>` does not hold the commit, say `not confirmed pushed (origin/<branch> does not hold it)` instead of `not pushed`, which is the only claim the script can back when the remote has no fetch refspec or maps the push elsewhere.

## Verified

New cases in the commit-board block of `tests/smoke.sh`. Each fails without its fix. None sends a signal to a process group.

- **Retry pushes.** Make a commit with a pre-push hook that sleeps, kill the script pid with SIGKILL during the hook, remove the hook, run `--push` again: exit 0, `origin` `main` equals `HEAD`, output does not say `nothing to commit`.
- **Retry names the problem.** The same with the remote made read-only (a pre-receive hook that rejects): exit 1 and the output names the unpushed short sha.
- **Push bound.** `LANEWORK_PUSH_TIMEOUT=2` and a pre-push hook that sleeps 30: the run ends in under 15 s with exit 1, the lock folder and stage folder are gone, `git status` shows the named path matching `HEAD`, and the output says `timed out`. A follow-up `--push` without the hook lands the commit.
- **Unwritable `push.err`.** A pre-commit hook that `chmod a-w`s the stage folder under a test `TMPDIR`: exit 1, `HEAD` equals the pre-run commit, and no "interrupted" line (the test restores permissions before cleaning up).
- **Saved-file sweep.** Plant a saved file named for a dead pid with an mtime two days old and another one hour old: after a run only the old one is gone.
- **Closing line.** A pre-push hook that moves `main` back to the owner's commit: the last output line names the run's commit, not the owner's.
- **Interrupted line.** With `remote.origin.push` mapping to another branch, a run stopped by SIGTERM right after the push prints `not confirmed pushed`, never `not pushed`.

## Done when

- `tests/smoke.sh` passes with the cases above, and `bash -n skills/work/scripts/commit-board.sh` is clean.
- Re-running the measurements in the Problem section on a throwaway repo gives: a retry that pushes, a hung push that ends at the bound, no commit left behind when `push.err` is unwritable, an old saved file swept, the closing line naming the run's commit.
- The header of `commit-board.sh` states the bound, `LANEWORK_PUSH_TIMEOUT`, the retry behavior and the sweep, and no other file restates them.
- `README.md` word counts still match (`tests/check-sizes.sh`).

## Risks

- A push that times out after reaching the remote leaves a local commit that origin already holds; the next `--push` then finds nothing ahead and prints the plain commit line. Harmless, but the timeout message must say "not confirmed".
- The group-kill wrapper is the one new moving part; it must not leave the hook child running, and must exit 124 only on its own timeout, not on a push that failed.
- The default of 120 s must be well above a normal push, but a slow remote on a large board can exceed it; the environment variable is the escape.
- The retry path pushes commits the current run did not make; the header already says `--push` carries earlier unpushed commits, so this matches.

## Recommendation

Build all of it except the SIGINT-to-the-script item, which is documented and harmless, so it is dropped. The retry push and the push bound are the real defects (an agent can believe a write reached origin, or hang for 90 minutes); the rest are small edits in the same function and cheapest done together.
