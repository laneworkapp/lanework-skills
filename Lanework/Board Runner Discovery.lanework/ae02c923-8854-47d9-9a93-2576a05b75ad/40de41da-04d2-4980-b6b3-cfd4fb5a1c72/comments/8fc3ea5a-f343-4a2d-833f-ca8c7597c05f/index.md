---
schema: 1
kind: comment
created:  {at: 2026-10-30T13:49:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
@rzen With no model in the loop, how does the runner know what a lane asks of it?

Options:
- A: The Pipeline lane actors table, matched by lane title, as `watch` and `dispatch` read lanes today.
- B: A runner-only key in each lane's frontmatter, such as `runner: {on_enter: shape}`.
- C: A small model job reads the lane bodies on each event.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
