---
schema: 1
kind: comment
created:  {at: 2026-11-21T15:43:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to main at `69dcfce` (branch `commit-board-retry-push`, head `e4d8a8a`).

**Changed**: `commit-board.sh --push` pushes a commit an earlier interrupted run left unpushed. A push is bounded by `LANEWORK_PUSH_TIMEOUT` (default 120 s; a bad value exits 2) and runs in its own process group, so a hung hook child dies with it. An unwritable `push.err` un-commits cleanly. Old saved files are swept. The closing line names the run's commit. 7 new smoke cases, each shown failing on the old script.

**Departures**: the SIGTERM case's wording is now `not confirmed pushed (origin/main does not hold it)`. The stderr redirect sits on the perl command, because a trap inside a redirected function kept the redirect.

**Review**: approved, adversarial stance, 13 mutants, no blocking findings.

**Evidence**: `tests/smoke.sh` on main at `da2bf8a`: `smoke: 331 passed`, rc 0.

**Left open** (filed as one Issues card): owner's staged entries not saved when try 1 takes the retry path; a huge timeout value disables the bound; no case for signal forwarding, for a git exit of 124, or for the sweep's live-pid guard; a tty credential prompt waits out the bound.

**CHANGELOG**: `commit-board.sh --push` now pushes a commit an interrupted run left behind, and gives up on a hung push after two minutes, keeping the commit.
