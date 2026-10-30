---
schema: 1
kind: comment
created:  {at: 2026-10-30T13:49:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
@rzen How does a card show that a job is working on it?

Options:
- A: State private to the runner, plus the START comment `work` already posts. Nothing new on the card.
- B: A lease key in card frontmatter, `claimed: {by, until}`, which interactive sessions also honor.
- C: Both.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
