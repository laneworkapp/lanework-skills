---
schema: 1
kind: card
title: "commit-board.sh: a --push retry that does not push, a push that can hang, and five smaller leftovers"
order: 4096
created:  {at: 2026-11-21T01:04:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T01:04:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
## Problem

Left open when [commit-board.sh: a rejected push loses the owner's staged work](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/08ccbaba-b51b-4860-937b-13037b41b85e) closed. All measured in throwaway repos during its review; the first two predate that card.

- **A retry that does not push.** After a run leaves its commit on HEAD but unpushed (a SIGTERM or SIGKILL mid-run), a second `commit-board.sh --push` finds nothing to commit, prints "nothing to commit" and exits 0 without pushing. Six of six measured rows. An agent that retries on a non-zero exit then believes the write reached origin.
- **A hang.** SIGINT sent to the whole process group while a pre-push hook runs can leave `git push` waiting forever on a local remote; the script sits in the foreground push and its cleanup never runs. One such run hung for 90 minutes until killed.
- **SIGINT to the script alone is dropped** while a git child runs; the run carries on. The header says so.
- **When `push.err` cannot be written** the script exits after printing "un-committing", without un-committing.
- **A SIGKILL leaves the saved-entries file** in the git folder; nothing sweeps it.
- **After the owner resets HEAD back during a good push**, the closing `git log -1` line shows the owner's commit as if it were the run's.
- **A remote with no fetch refspec, or a push mapping to another branch name**, makes the interrupted line say "not pushed" after a good push.

## Wanted

- `--push` with nothing to commit and HEAD ahead of the upstream ref pushes, or exits non-zero saying so.
- A bound on the push (a timeout) so the cleanup always runs.
- The smaller items fixed or stated where the script prints.

## Done when

- A smoke case: a commit left unpushed by an interrupted run is pushed by the next `--push` run, or that run exits non-zero and names the unpushed commit.
- A smoke case: a push that never returns ends within the bound, with the index as before the run.
