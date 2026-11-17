---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:39:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this card as lead, top of Approved after the dispatch card closed.**

- **Branch**: `work-helpers`, worktree `.claude/worktrees/work-helpers`, cut from main at `a0d281c`.
- **Team**: one fixer, then an adversarial reviewer (a script that commits and pushes, with a lock).
- **Risk in the body, now gone**: smoke is green on main (`smoke: 152 passed`), the guide stamp is v118.
- **`post-ask.sh --for`**: stays required, as the frozen body says. The default handle that landed with 9e04cdec is not wired in here.
- **Gate**: `tests/smoke.sh`.
