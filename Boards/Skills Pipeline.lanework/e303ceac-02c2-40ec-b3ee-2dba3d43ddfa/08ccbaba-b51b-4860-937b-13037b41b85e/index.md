---
schema: 1
kind: card
title: "commit-board.sh drops the owner's staged version of a path when a push is rejected"
order: 82944
created:  {at: 2026-11-20T19:07:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T01:04:30Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
When a push is rejected and `commit-board.sh` takes its commit back, the owner's staged version of a named path is replaced by HEAD's, so a later failure leaves their staged work gone while the script says the index is untouched.

Found in review of [commit-board.sh drops the owner's staged version of a path when a pre-commit hook fails](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/5ca41314-0792-4f4c-8e53-0d771d1a8dca). This card went from Issues straight to Approved, so the sections below were written at the start of the build, from a fresh reproduction.

## Reproduce

Measured in throwaway repos (a bare origin and a work clone under `mktemp -d`, global git config shut out), on `skills/work/scripts/commit-board.sh` as on `origin/main` at `2a600e3`, run as `commit-board.sh --push "board write" P.md D`. The harness, `repro-08ccbaba.sh`, and its raw output before and after the fix are in the build session's scratch folder, not in the repo; the smoke cases below are the lasting check.

The owner's state before each run, nine entries in `git status --short`:

- Named file `P.md`: `v2` staged, `v3` on disk (`MM P.md`).
- Inside the named folder `D`: a staged new file (`A  D/add.md`), a staged deletion (`D  D/del.md`), a staged rename (`R  D/old.md -> D/new.md`), and an unstaged edit (` M D/card.md`).
- Outside the named paths: a staged-only edit (`M  Q.md`), a staged deletion (`D  Xdel.md`), a staged rename (`R  Xold.md -> Xnew.md`) and a staged new file (`A  Xadd.md`).

Results on the unfixed script:

- **(a) Push rejected once, then the retry's pre-commit hook fails.** Exit 1, HEAD unchanged. Last lines: `push rejected (try 1 of 5); un-committing ...` then `git commit failed (a pre-commit or commit-msg hook?); nothing committed, the index untouched`. The index is not untouched. Under the named paths all four staged changes are gone: `P.md` now holds HEAD's `v1` (status ` M`), the staged deletion and rename became unstaged (` D D/del.md`, ` D D/old.md`), and the two staged new files became untracked (`?? D/add.md`, `?? D/new.md`). In `git ls-files -s`, still 7 entries, but `P.md` changed blob, `D/add.md` and `D/new.md` left the index, and `D/del.md` and `D/old.md` came back. The four entries outside the named paths (`Q.md`, `Xdel.md`, `Xold.md -> Xnew.md`, `Xadd.md`) were kept.
- **(b) Push fails five times.** Exit 1, HEAD unchanged, last line `push failed 5 times; nothing committed, files on disk`. Same index and status as (a), entry for entry.
- **(c) Push rejected once, then succeeds.** Exit 0, prints the new commit. The named paths match HEAD in index and on disk (`git status` lists only the four outside entries). This is the intended behavior and stays.
- **(d) Push rejected by a competing commit that changes `P.md` upstream.** Exit 1: the retry's fast-forward is refused (`Your local changes to the following files would be overwritten by merge: P.md`). HEAD unchanged; same loss under the named paths as (a).
- Not reproduced on any route: a loss outside the named paths. The un-commit's `git reset -q -- <paths>` only touches the named paths.

Cause: after `git update-ref` takes the commit back, `sync_index` runs `git reset -q -- <paths>`, which sets the index for the named paths to HEAD. The owner's staged entries under them were never saved anywhere, so no later step can put them back. The EXIT trap would reset again on the same route, because `LANDED` is still set.

## Change

One file, `skills/work/scripts/commit-board.sh`; smoke cases in `tests/smoke.sh`.

- **Save the owner's staged entries once, before the first `git commit`.** `save_owner` lists the files under the named paths whose index entry differs from `PRE` (`git diff --cached --name-only --no-renames -z PRE -- <paths>`; a rename counts as both of its names) and writes their `git ls-files -s -z` entries to the private stage folder. A file the owner deleted is in the list with no entry. It runs on try 1 only.
- **The un-commit restores instead of syncing.** After `update-ref`, `restore_index` runs: `git reset -q -- <paths>` (the named paths back to HEAD, as today), then `git rm -q -r -f --cached --ignore-unmatch` on the saved names, then `git update-index -z --index-info` from the saved entries. Net effect: the index under the named paths equals HEAD plus exactly what the owner had staged. Then `LANDED` and `PRE` are cleared, since nothing of this run is on HEAD.
- **The EXIT trap follows the same rule**, still only while the lock is ours: when our commit landed and HEAD is no longer that commit, it restores; when our commit is on HEAD (or HEAD moved off `PRE` before `LANDED` was set), it syncs as today. A SIGTERM or SIGINT between `update-ref` and the restore therefore restores too.
- **Messages only say what is true.** A hook failure on try 1 still says `the index untouched`. On a later try it says `the index restored to what was staged before the run`. Five failed pushes end with `push failed 5 times; nothing committed, files on disk, the index restored to what was staged before the run`. If a restore fails, the script prints a warning and both messages say `the index for the named paths NOT restored to what was staged before the run (check git status)`.
- **A successful commit and push is unchanged**: `sync_index` after the commit, the index matching HEAD for the named paths.
- **Header comment**: the paragraph on index syncing is rewritten to describe the restore, and the window line now says what was measured: a SIGKILL anywhere from `git commit` starting (hooks included) to the line after it, or between `update-ref` and the restore.
- **Ride-along, one line**: `skills/work/scripts/lint-ask.sh:15` exits 2 with a usage line when given no arguments, instead of 1 from `${1:?}`.

**When the retry fast-forwards onto upstream commits.** The owner's staged state is a set of index entries (blob, mode) for specific files, not a diff. Two cases:

- An upstream commit touches a file the owner had staged. After the restore that file's index entry differs from HEAD, so `git merge --ff-only` refuses to overwrite it, and the script stops with exit 1 on its existing "fast-forward refused; uncommitted changes overlap" message. Measured in (d): HEAD kept, the index exactly as before the run. The script never merges the owner's staged version with upstream's; refusing and leaving the index alone is the only safe answer, and git already enforces it.
- An upstream commit touches a file under a named folder that the owner had not staged. The restore puts that file at HEAD, the fast-forward updates it, and the saved entries never mention it, so no stale version is put back. Measured in a variant of (b) (`repro-e.sh`): after five failed pushes, HEAD is the upstream commit, `D/clean.md` is at upstream's version in HEAD, index and disk, and every owner entry is as before the run.

Saving once, before the first commit, is correct for both cases: the saved files cannot change upstream without stopping the fast-forward, and a per-try save would capture whatever an earlier failed restore left.

## Verified

New smoke cases in `tests/smoke.sh`, in the commit-board block, each starting from the card file staged at `r2` with `r3` on disk and a staged new file `n.md` in the card folder, the folder named:

- `commit-board.sh: a rejected push, then a failed hook on the retry: HEAD, index and status as before the run, and it says restored, not untouched`. Fails on the unfixed script (status ` M` on the card, `?? n.md`).
- `commit-board.sh: five failed pushes: HEAD, index and status as before the run (the staged version and the staged new file kept)`. Fails on the unfixed script (same status).
- `commit-board.sh: a rejected push, then a good one: the disk versions committed and pushed, the index matches HEAD on the named folder`. Passes on the unfixed script, which is right: this route never lost anything. It guards the fix against restoring after a success.
- The existing hook case now also checks that a first-try hook failure says `the index untouched`.
- `lint-ask with no arguments exits 2 (usage), not 1 (violations)`. Fails on the unfixed script (exit 1).

## Done when

- `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID tests/smoke.sh` passes, with the four new cases above in its output.
- The build's repro harness (`repro-08ccbaba.sh`, in the session's scratch folder) run on the fixed script shows, for (a), (b) and (d), the same `git ls-files -s` and `git status --short` after the run as before, and HEAD unchanged.
- `grep -n 'the index untouched' skills/work/scripts/commit-board.sh` finds it only as the initial value of the message used on a try-1 hook failure.
- `lint-ask.sh` with no arguments: `skills/work/scripts/lint-ask.sh; echo $?` prints the usage line and `2`.

## Risks

- **The owner staging while the script runs.** The lock serialises commit-board runs, not the owner's own `git add`. A file the owner stages under a named path between the save and an un-commit is reset to HEAD by the restore. This was true of the old reset as well; the window is now the same, not wider.
- **Restored entries carry no stat data.** `git status` re-hashes them once; content and mode are exact.
- **SIGKILL windows remain**, as the header now says, and a SIGKILL between `update-ref` and the restore leaves the old loss. Nothing in a shell script can close that window.
- **Unmerged entries** (stages 1 to 3, an owner mid-conflict) are saved and put back by `--index-info` as listed. Reasoned, not measured.
- **Another branch, `lint-ask-line1`, edits `lint-ask.sh`.** This change touches only line 15 there, so a merge should be clean; the lead should check.

## Decided

Ruled by the owner on this card, 2026-11-20: **0.9.0 is held until this is fixed too.** Not taken: shipping it in 0.9.1.
