---
schema: 1
kind: comment
in-reply-to: a08f35ca-b505-456f-adb3-046bac1c7b5d
created:  {at: 2026-10-10T02:01:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T02:01:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
**`/heal` already builds on [76299d5a](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/76299d5a-90d1-4942-9a53-97d47e248fd0): its data step is that card's `heal-board.py`, run and cited, not copied.**

- **Layering**: `heal-board.py` repairs damage, and `heal-descriptors.py` (new) brings lane bodies and the pipeline sheet up to the templates. `/heal` runs the first, then the second. `lanework/references/writes.md` § Healing points to `heal` for the whole-board case.
- **Which copy**: unchanged. The board's `.schema/bin/lanework-heal.py` wins when the app ships it ([9340580b](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/9340580b-ccef-4fc4-b439-cc618cd63023)), else the skill's copy.
- **One deliberate difference**: [76299d5a](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/76299d5a-90d1-4942-9a53-97d47e248fd0) ruled that a repair never restamps `modified`. A descriptor edit does restamp, as the running agent, because it changes a body's content rather than repairing its form.
- **Stays skill-side**: the descriptor half reads the skills' own lane templates, so the app can't ship it beside the validator.
