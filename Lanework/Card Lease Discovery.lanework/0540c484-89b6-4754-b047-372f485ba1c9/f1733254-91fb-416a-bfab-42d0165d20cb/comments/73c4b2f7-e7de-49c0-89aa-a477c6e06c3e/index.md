---
schema: 1
kind: comment
created:  {at: 2026-11-14T13:51:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:51:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
@anyone How should an agent stake a lease on a free card?

Options:
- A: Write, wait, read back. Renewal catches and records a collision.
- B: Take an atomic temp-folder lock, write, drop the lock.
- C: Move the card to a lane, then write.
- Recap: Explain this in plain terms first

Recommended: A, provisionally. B is the fallback if a collision is recorded.
If no answer: A stands when the round closes.
Context: the comment above.
