---
schema: 1
kind: comment
created:  {at: 2026-11-14T13:45:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:45:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
@anyone How should an agent stake a lease on a free card?

Options:
- A: Write it, wait a second, read it back. A changed `by` means back off.
- B: Take an atomic temp-folder lock, write it, drop the lock.
- C: Move the card to a lane, then write it.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
