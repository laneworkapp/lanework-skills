---
schema: 1
kind: comment
created:  {at: 2026-11-17T17:51:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this card as lead, first of the cards that call the lease script.**

- **Order**: [the lease trial card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b) sits higher in Approved; it and the watch card build after this one. The owner's install move is the owner's to run.
- **The lease script as built** ([its card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb), main at `9174bb9`), where it differs from this body's wording:
  - `check` needs `--model` and exits 0 held, 3 lost, 4 never held, 2 with no session id. So "outcome 0" here is exit 0 or 4, and with no session id `post-comment.sh` skips the check and writes as today.
  - a lost lease also covers `claimed` deleted by the owner.
- **Lead's ruling, `move-card.sh`**: it gains the same check in this card. The body's Depends-on says the check is "added by whichever card builds second", and the work helpers built first. Its Files list says the other work scripts are not touched; Depends-on wins, since the ruling is that every card-writing script checks first. `post-ask.sh` wraps `post-comment.sh`: on a lost lease it must leave `waiting` unwritten too, measured in smoke. `file-card.sh` makes a new card, which has no lease.
- **Gone since the body was written**: the dispatch skill. `watch/scripts/arm-pass.sh` still reads a START as a claim; that is the watch card's.
- **Smoke on main**: 203, green; the stamp gate no longer fails.
- **Branch**: `work-lease`, worktree `.claude/worktrees/work-lease`, cut from main at `ff5ee47`.
- **Team**: one fixer on the higher tier (lease timers in tests), then an adversarial reviewer. **Gate**: `tests/smoke.sh`.
- **CHANGELOG**: at release, shared with the lease card.
