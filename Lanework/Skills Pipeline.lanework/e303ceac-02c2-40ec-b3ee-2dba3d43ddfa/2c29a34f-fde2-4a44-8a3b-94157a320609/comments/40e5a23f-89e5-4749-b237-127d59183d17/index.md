---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:36:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Merged to main as 2dc7b75 (branch head b0d9665, reviewer APPROVE round 2 d3bee28c). The stamp reads `lanework-agent-guide v114`, and smoke is green in the main checkout again. Card closed.**

- **Gate**: `tests/smoke.sh` at b0d9665 in the fixer's worktree: exit 0, "smoke: 129 passed" (7b32bf98). The same head with the app's v114 guide and `.schema/` copied in: exit 0, 129 passed, twice (25a7cbe, then b0d9665).
- **Main after the merge**: `tests/smoke.sh` in the main checkout at 2dc7b75: exit 0, "smoke: 129 passed", stamp case "not behind the board's guide v114 and schema v1". The app's v114 files were committed first, as bfb5f14.
- **Review**: round 1 REQUEST-CHANGES (c4122cd5): a list-form `waiting` in block form left `settle-question.sh` and `resolve-ticket.sh` writing a card that does not parse. Fixed with smoke cases that fail on the old code; `frontier.sh` reads both forms.
- **Folded in from the review notes**: `lint-ask.sh` ignores `@` in code spans and links; `writing.md` names no guide version and smoke checks every skill `.md` for one; the root-key mapping branch of the heal has a case again; README date line.
- **Filed, not done here**: move receipts in watch and dispatch (42019d3d, Ideas); the version check's missing control (16ac871d, Issues).
- **Deferred by the body**: plan tickets' "Depends on" as relations, classifying a relation change in `classify-event.sh`, re-basing `heal-board.py` on heal v5.
