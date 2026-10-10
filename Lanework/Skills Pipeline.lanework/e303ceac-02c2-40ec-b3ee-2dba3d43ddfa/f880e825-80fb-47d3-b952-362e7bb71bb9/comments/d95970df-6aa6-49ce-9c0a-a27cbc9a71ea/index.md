---
schema: 1
kind: comment
created:  {at: 2026-10-10T18:40:50Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "plan skill"}}
modified: {at: 2026-10-10T18:40:50Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "plan skill"}}
---
**Built and verified in 8a3dd62: `skills/plan/` (5 references and SKILL.md, 5 templates, 5 scripts), wired into plugin.json, board-kinds, lanework's SKILL.md and the README. Done-when met.**

- **Smoke**: 10 new plan cases, covering founding, numbering, which lane a ticket lands in, refused dependencies, claim refusals, unblocking with two dependencies, out of scope, frontier drift and `file-record.sh --from Working`.

  ```
  check-sizes: 57 rows, 0 wrong
  smoke: 102 passed
  ```
- **Calls made while building**: the board is founded only once charting finds fog, so a "no board needed" stop leaves nothing behind. A named Working ticket left waiting on the owner is resumed without a new claim. Ticket label values carry their own icons.
- **Not done**: no CHANGELOG entry, version bump or release. Those wait for the owner.
