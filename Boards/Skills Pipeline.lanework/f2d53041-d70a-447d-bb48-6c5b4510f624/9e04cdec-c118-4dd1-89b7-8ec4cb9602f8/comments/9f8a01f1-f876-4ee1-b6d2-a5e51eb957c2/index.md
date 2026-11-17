---
schema: 1
kind: comment
created:  {at: 2026-11-12T18:56:43Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
**Shaping started: reading the v114 to v117 guide diff against the skills.**

- **Plan**: confirm each drift candidate in the filing comment against `skills/`, add any it missed, then rewrite the body to the ready-to-build bar.
- **Found so far**: `lint-ask.sh` treats a body that does not mention the board's own handle as a record, so a correct `@anyone` ask would pass the lint unchecked. `file-question.sh` and `question-card.md` write the machine's handle into `waiting.for`.
