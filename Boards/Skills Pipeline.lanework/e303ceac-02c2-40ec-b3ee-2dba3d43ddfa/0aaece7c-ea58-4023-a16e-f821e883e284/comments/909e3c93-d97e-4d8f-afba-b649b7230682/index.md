---
schema: 1
kind: comment
created:  {at: 2026-11-27T17:41:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T17:41:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this in a worktree on branch `v122-leftovers`, while the v122 card waits on its last test run.**

- **Base**: local `main`, which holds the v122 change this card corrects. That change is merged and not yet pushed.
- **Plan**: a fixer builds the five rows of Scope with a failing case first for the padded name and the duplicate no-emoji entries. A separate reviewer then reads the branch.
- **Gate**: `tests/smoke.sh --only braces,merge` on the branch, the full run before the merge.
- **Settled already**: padded names are refused, not trimmed. The shared exit causes are listed once in `lib.sh`.
- **Accepted limit**: if the v122 run on `main` fails and that change moves, this branch is rebased onto the fix.
