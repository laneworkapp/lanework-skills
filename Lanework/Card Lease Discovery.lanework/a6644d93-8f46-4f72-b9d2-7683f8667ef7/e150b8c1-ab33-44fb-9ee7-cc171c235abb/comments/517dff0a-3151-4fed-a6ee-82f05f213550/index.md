---
schema: 1
kind: comment
created:  {at: 2026-11-14T04:27:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T04:27:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
@anyone What should a lease's `by` hold to identify its holder?

Options:
- A: The stamp's `by` map, with the harness session id as a required `session`.
- B: A token the claim script mints and keeps in a state file.
- C: Name, host and process id.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
