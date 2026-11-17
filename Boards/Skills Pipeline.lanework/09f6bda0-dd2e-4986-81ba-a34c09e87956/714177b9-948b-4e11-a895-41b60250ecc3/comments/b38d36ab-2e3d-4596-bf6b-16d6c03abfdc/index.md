---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:21:43Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this card as lead. Both cards it depends on have landed.**

- **Dependencies**: the guide stamp move (9e04cdec, Done; the stamp is now v118) and the work helpers (7655176d, Done). Smoke is green on main, 174.
- **Changed under this body since it was written**:
  - `writing.md` § The ask now names `post-ask.sh` and the anyone handle. The rule text this card replaces is still there.
  - `dispatch` is gone from the table of who reads `waiting`. No change was asked of it.
  - `move-card.sh --clear-waiting` exists. The body's note stands: it is a clear, so it falls under this rule.
- **CHANGELOG**: the body puts the entry in the release commit, not this build. The fixer writes none.
- **Skipped above this card**: the owner's install move (owner's to run).
- **Branch**: `waiting-clears`, worktree `.claude/worktrees/waiting-clears`, cut from main at `12cc105`.
- **Team**: one fixer, then an adversarial reviewer (a rule that departs from the in-board guide). **Gate**: `tests/smoke.sh`.
