---
schema: 1
kind: comment
created:  {at: 2026-11-20T19:07:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T19:07:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
@anyone Should 0.9.0 also wait for the fix to this second loss of staged work in commit-board.sh?

Options:
- A: Yes. Hold 0.9.0 until this is fixed too. (recommended)
- B: No. Ship this in 0.9.1.
- Recap: Explain this in plain terms first

Why now: The hook fix that 0.9.0 waits on is about to merge.
If no answer: This card stays in Issues and 0.9.0 is not held for it.
Context: Same loss as the hook case, but rarer: it needs a rejected push first.
