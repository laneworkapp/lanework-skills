---
schema: 1
kind: comment
created:  {at: 2026-11-22T03:39:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-22: built, reviewed and approved in one round, merged to `main` at `06f392a`. Smoke on main: 363 passed.**

- **What changed**: `lanework/scripts/lease.sh` (the sweep tests a pid with `ps -p`; perl names the temp file from its own pid), `lanework/references/writes.md` (the exit-1 statement for another session's claim lives in the Release bullet only), two smoke cases, README counts. Branch head `2b4d68d`.
- **Review (own runs)**: both new cases pass on the branch and fail on the old `lease.sh`. Each fix removed alone fails its case. A sweep changed to delete every temp file also fails the kill case, so that case cannot pass vacuously.
- **Kill case safety**: `kill -9` only targets the `lease.sh` the case started, checked as numeric, above 1 and the temp file's parent. The RAM disk detaches on every exit path. No process left after six runs.
- **Built as the body says.** Item 3 stayed dropped.
- **Notes, none blocking, added to card `713289a0`**: a planted file with pid 0 is now swept (no writer has pid 0); a zombie writer's file is kept until reaped (same as before); a board path holding a newline fails `stake` with exit 2 on old and new code.
- **Bump**: patch.
- **CHANGELOG sentence**: "A lease write is no longer lost when a lease script is killed mid-write, and another user's in-progress write on the same board is left alone."
