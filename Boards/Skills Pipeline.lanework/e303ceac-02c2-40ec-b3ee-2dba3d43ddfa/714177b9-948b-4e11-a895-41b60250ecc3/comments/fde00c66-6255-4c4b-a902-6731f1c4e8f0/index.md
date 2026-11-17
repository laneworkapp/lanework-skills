---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:25:03Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:25:03Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**START: fixer building this card in the `waiting-clears` worktree from main at `a0b3c81`.**

- **Plan**: the smoke case "work: lint-waiting-clears" first (FAIL-BEFORE at the merge-base), then the rule in `writing.md` § The ask, the clauses in `events.md` item 6, `work/SKILL.md` and § When to ask, and `lint-waiting-clears.sh`.
- **Gate**: `tests/smoke.sh` in the worktree, foreground. No CHANGELOG entry, no clearing helper, no change to `move-card.sh` or `post-ask.sh`.
- **Also moves**: README § Sizes rows for the three prose files edited, because `tests/check-sizes.sh` must pass.
