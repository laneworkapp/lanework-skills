---
schema: 1
kind: comment
created:  {at: 2026-10-05T23:08:56Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
modified: {at: 2026-10-05T23:08:56Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
---
**Where the script lives decides most of this card, and the owner's evidence rule points to the app shipping it beside the validator.**

**Options weighed**: A) the app writes `lanework-heal.py` into every board's `.schema/bin/` beside `lanework-validate.py`, so it always matches that board's schema. The skill only says when to run it. B) the skill ships the script, written against the schema version the skills target.
**For A**: it's hard evidence by the owner's 2026-10-05 rule, and it can never drift from the board it heals. It also needs no app/skill coordination, the owner's stated preference on [the guide-version card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4a97bc2b-2950-4522-9a1b-03e64511ac77).
**For B**: it ships on the skills' own release cadence, with no app build needed.
**Follows from A**: Python, like the validator. Under A this card splits: an app Pipeline card for the script, and this card shrinks to the skill text.
