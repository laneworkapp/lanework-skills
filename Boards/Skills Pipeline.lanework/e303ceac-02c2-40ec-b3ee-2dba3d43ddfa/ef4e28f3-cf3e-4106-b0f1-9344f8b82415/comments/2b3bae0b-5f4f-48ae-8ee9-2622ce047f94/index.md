---
schema: 1
kind: comment
created:  {at: 2026-11-21T19:23:27Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-21: built, reviewed and approved, merged to `main` at `5cbf55c`. Smoke on main at `a8c5b73`: 354 passed, first run, at a load average of 240.**

- **What changed**: `lanework/scripts/lease.sh` (the timer retries when its card is between lanes, treats a failed read as a miss, and survives a comment that vanishes while it reads the thread); `tests/smoke.sh` (scripts' output read whole through `bfirst`, a guard that refuses a script piped into `head` or `grep -q`, case 12 renews before it lists, new timer cases). Branch head `2fc41a1`.
- **Review: request-changes in round 1** (the two-lanes retry had no case), **approved in round 2.** Each new rule fails a case when mutated (reviewer's runs).
- **Done when, not met by design**: the lines asking for repeated full runs under load. No load was generated on the owner's machine. Evidence instead: the three runs on main before this merge failed on the flakes this card names (load 130 to 380); the first run after it passed at load 240.
- **The guard earned its keep at once**: it caught a `| head -1` helper that the Recap-click branch had added.
- **Behavior note**: the timer exits about three polls after its card is deleted.
- **Left open, filed as a follow-up card**: `mem_save` in the notice branch can bring the memory file back just after a release; the guard's pattern is narrow (`sed q`, `awk exit`, `| read` are not matched); `bq()` discards an exit code.
- **Bump**: patch.
- **CHANGELOG sentence**: "A card lease no longer stops renewing when the card is moved between lanes while it is held."
