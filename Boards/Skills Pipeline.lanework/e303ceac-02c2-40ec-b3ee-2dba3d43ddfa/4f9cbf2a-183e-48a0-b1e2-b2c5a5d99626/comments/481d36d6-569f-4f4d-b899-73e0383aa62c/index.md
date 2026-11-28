---
schema: 1
kind: comment
created:  {at: 2026-11-27T21:25:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T21:25:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this in a worktree on branch `board-signature`.**

- **Base**: local `main`, with the padded-name change merged and its full test run in progress. If that run fails and `lib.sh` moves, this branch is rebased.
- **Plan**: the writer `sign-board.py` first, with its own cases on throwaway boards. Then `sign_board` in `lib.sh` and one call per writer. Then `writes.md`, the README line and the smoke cases.
- **Draft**: the sketch from the app's watch session is read for ideas. Nothing is copied in without the fixes the body names.
- **Settled already**: every writer signs, only on a board with its seeded `.gitignore`, never on a failure path, never from the lease timer's renewals.
- **Gate**: the new smoke cases and the sections the change touches on the branch. The full run before the merge. A separate reviewer reads the branch.
