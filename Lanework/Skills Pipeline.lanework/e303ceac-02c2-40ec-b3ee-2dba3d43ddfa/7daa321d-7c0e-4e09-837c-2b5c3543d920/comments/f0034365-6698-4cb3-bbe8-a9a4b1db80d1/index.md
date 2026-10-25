---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:31:13Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T10:31:13Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
**START: taken from the top of Approved into Active. The build runs on branch `type-kind-cube`, in worktree `.claude/worktrees/type-kind-cube`.**

- **Decided**: the glyph is `cube`, as ruled on 2026-10-13. No open calls are left.
- **Plan**: a sonnet fixer changes the `type` row in `skills/lanework/templates/label-kinds.md`, along with any smoke fixture that pins the old glyph, and runs `tests/smoke.sh`. A sonnet reviewer with the standard stance reviews the branch. The lead then merges, re-runs smoke on main and closes the card.
- **Accepted limitation**: the board's guide in the main working tree is now v101, uncommitted, while the skills are stamped v93. Smoke runs from clean checkouts, so that drift is left for its own card.
