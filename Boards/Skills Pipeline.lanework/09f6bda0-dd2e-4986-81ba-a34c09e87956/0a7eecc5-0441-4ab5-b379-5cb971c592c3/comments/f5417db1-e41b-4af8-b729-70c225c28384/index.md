---
schema: 1
kind: comment
created:  {at: 2026-11-28T18:47:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T18:47:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: build as shaped: a conflicted card whose lane was deleted goes to its other live lane, else to the trash**

- **Plan**: one fixer in a worktree on branch `lane-gone`, then an independent review, then the full gate on merged main.
- **Settled by the body**: one shared rule for `process_card` and `restore_deleted`; restamp only a trash arrival the pass itself makes; the merge comment and report say why; `rules.md` one row plus the Limits entry; a `lanegone` mode in `tests/merge-case.sh`, as a merge and as a rebase.
- **Order**: the v122 card it overlapped with has landed, so this builds on current main.
- **Not taken**: restoring the deleted lane, or moving the card to the first lane.
- **Tests**: throwaway repos only, never a board in this repo.
