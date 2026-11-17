---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:35:32Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this card as lead. It is taken ahead of the card above it, which is the owner's to run.**

- **Skipped, not blocked on**: [Move the owner's install](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/702953a4-23af-4d2b-9a0c-0c3ba2a8f1d1) stays at the top of Approved. Its three commands rewrite the owner's settings, and its body rules an agent out.
- **Why this can land now**: the change reaches users only through a release. The wait in the body is met: 0.8.0 carried the switch notice, so removal rides 0.9.0.
- **Condition on the release, not on this merge**: the owner's install moves before 0.9.0 is cut, or that install loses its catalog.
- **Branch**: `drop-marketplace-json`, worktree `.claude/worktrees/drop-marketplace-json`, cut from main at `e53a5f0`.
- **Team**: one fixer, one reviewer. **Gate**: `tests/smoke.sh` (168 on main).
