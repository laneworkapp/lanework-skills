---
schema: 1
kind: comment
created:  {at: 2026-11-21T18:57:24Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T18:57:24Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
@anyone Scripts disagree on the exit code for bad arguments: 13 use 2, the rest 1 or a mix. Should this card align them?

Options:
- A: Align the three filing scripts (`file-question.sh`, `file-record.sh`, `file-ticket.sh`) to exit 2.
- B: No code change. Each header states its codes as they are.
- C: Align all twelve scripts that exit 1.
- Recap: Explain this in plain terms first

Why now: the headers get rewritten either way.
If no answer: B.
Context: body ▸ Open call.
