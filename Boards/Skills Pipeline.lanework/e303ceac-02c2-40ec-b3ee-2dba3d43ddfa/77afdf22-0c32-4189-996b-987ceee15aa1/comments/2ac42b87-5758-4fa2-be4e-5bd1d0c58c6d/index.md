---
schema: 1
kind: comment
created:  {at: 2026-11-22T05:37:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-22: built, reviewed and approved, merged to `main` at `66d0b6a`. Smoke on main: 375 passed.**

- **What changed**: 28 scripts under `skills/*/scripts/`, `lanework/references/writes.md` (the convention, stated once, and the two lease additions), `tests/smoke.sh` (12 new cases), README counts. Branch head `db9dfe8`.
- **Code fixes, items 1 to 8**: all built. Each fails on the old code and passes on the branch (reviewer's own runs).
- **Convention (option C)**: a wrong call exits 2 in all twelve scripts, a refusal stays 1, a lost lease stays 3, the heal scripts keep 64. The reviewer ran 54 cases across the twelve, and the boards were byte-identical afterwards.
- **Headers, items 9 to 30 without 24**: a second reviewer read every touched header against its code and found no false statement.
- **Guard**: one smoke case runs every script with no arguments and requires the exit code in the header's comment lines or docstring.
- **Review: two reviewers, two rounds.** Headers approved in round 1. Behavior requested changes: the guard's header check was satisfied by code lines. Fixed and approved in round 2.
- **Built differently from the body**:
  - Item 3: the `mkdir` already sat after the render on `main`. Only the render failure changed, from exit 255 to exit 2.
  - `frontier.sh` and `merge-board.sh` also exit 2 on a first argument starting with `-` (lead's addition, so their headers are true).
  - Done-when says `grep -L -i 'exit [0-9]'` lists only `lib.sh`. It lists nothing, because `lib.sh` holds an `exit 2`.
- **Left open, added to card `713289a0`**: an unreadable `--body` exits 2 in three scripts and 1 in two others; four small header omissions; seven scripts print "unknown argument" without the usage line.
- **Bump**: minor (exit codes change).
- **CHANGELOG sentence**: "A wrong call to any script now exits 2 and a refusal exits 1, every script's header states its exit codes, and moving a card no longer leaves a comment behind when the move is refused."
