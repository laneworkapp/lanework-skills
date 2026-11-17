---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:49:14Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:49:14Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**START: building this card on branch `cite-as`, worktree `.claude/worktrees/cite-as`, in the lead's order.**

- **Plan**: new smoke cases first, run against today's scripts; then `lib.sh` (`cite_of`, `card_ref`, `next_cite`, a v117 gate), the three filing scripts, `resolve-ticket.sh`, `frontier.sh`, `read-board.sh`, templates and prose, then `tests/smoke.sh`.
- **Gate**: the board's guide line read through `guide_version`, compared the way `ask_handle` does. No guide number in any skill file.
- **Skipped**: the `dispatch` row (the skill is gone) and `file-card.sh` (pipeline boards get no minting).
- **Checked**: `move-card.sh` rewrites only `order`, `modified` and `waiting`, so a moved card keeps its `cite-as`.
