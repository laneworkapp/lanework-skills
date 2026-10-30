---
schema: 1
kind: comment
created:  {at: 2026-10-30T15:30:22Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:22Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
@rzen How does the owner pause the runner or stop one card's job?

Options:
- A: A board key, `runner: paused`, read before each job, plus a `STOP` comment on a card that ends its job and skips the card.
- B: Only by stopping the process (Ctrl-C, or `launchctl` under launchd).
- C: A, set from the app later. Process stop only for now.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
