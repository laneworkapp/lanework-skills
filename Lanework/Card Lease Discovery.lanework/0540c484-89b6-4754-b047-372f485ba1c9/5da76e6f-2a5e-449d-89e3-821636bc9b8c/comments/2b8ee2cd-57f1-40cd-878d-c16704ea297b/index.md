---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:03:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:03:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
@anyone Where does the lease mechanism live?

Options:
- A: One lanework script that every skill calls. It runs the renewal timer too.
- B: Each skill writes the key itself, following one rule.
- C: A shared lib function, with each skill running its own timer.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
