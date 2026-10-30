---
schema: 1
kind: comment
created:  {at: 2026-10-30T15:30:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
@rzen What may a job do without asking, given that nobody is there to approve a prompt?

Options:
- A: `dontAsk` with an allowlist per job kind, builds adding their worktree and gate commands.
- B: Board jobs as in A, build jobs in `bypassPermissions` inside their worktree.
- C: `bypassPermissions` for every job.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
