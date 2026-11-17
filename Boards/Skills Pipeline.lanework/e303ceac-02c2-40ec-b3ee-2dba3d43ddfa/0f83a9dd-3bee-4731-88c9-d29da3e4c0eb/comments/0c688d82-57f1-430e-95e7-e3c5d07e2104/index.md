---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:43:32Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this card as lead, ahead of the lease trial card above it, which calls this script.**

- **Order**: [the lease trial card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b) sits higher in Approved and depends on this one, so this builds first. The owner's install move is the owner's to run.
- **Changed under this body since it was written**:
  - Smoke is green on main (183); the guide-stamp gate no longer fails.
  - "the watch and dispatch arming pass" is the watch arming pass only: dispatch is retired.
  - `work/scripts/move-card.sh` and `post-ask.sh` now rewrite card front matter. Neither is in this card's Files; the fixer reports whether they keep a block-form `claimed` intact.
- **CHANGELOG**: at release, per the body. The fixer writes none.
- **The two manual checks** (the app write-back, the timer outliving its call) are the lead's, after the script is merged. The app check needs a card open in the Lanework app.
- **Branch**: `lease-script`, worktree `.claude/worktrees/lease-script`, cut from main at `42b5a98`.
- **Team**: one fixer on the higher tier (a background timer and a two-session race), then an adversarial reviewer. **Gate**: `tests/smoke.sh`.
