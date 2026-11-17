---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:03:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:03:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
@anyone Does a lease need a guard against a wrong clock?

Options:
- A: No. One machine means one clock, and `until` is UTC from it.
- B: Yes. Check `until` against the file's modification time.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
