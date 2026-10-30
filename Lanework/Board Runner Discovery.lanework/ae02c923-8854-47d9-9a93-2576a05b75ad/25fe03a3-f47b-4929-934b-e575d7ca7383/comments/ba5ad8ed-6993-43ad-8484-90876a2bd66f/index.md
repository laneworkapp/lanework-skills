---
schema: 1
kind: comment
created:  {at: 2026-10-30T13:49:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
@rzen When the owner replies to an ask, does the next job resume the earlier session or start fresh?

Options:
- A: Always fresh. Each job reads the card and its thread, and the board is the memory.
- B: Resume the card's last session by its id.
- C: Resume when the last session is under a day old, else fresh.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
