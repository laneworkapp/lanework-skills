---
schema: 1
kind: comment
created:  {at: 2026-10-30T15:30:23Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:23Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
@rzen What happens when a job fails: a non-zero exit, or its turn cap reached?

Options:
- A: No retry. The runner posts a short record on the card naming the failure, releases the lease, and skips the card until the owner comments again.
- B: Retry once, then A.
- C: Retry until it succeeds.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
