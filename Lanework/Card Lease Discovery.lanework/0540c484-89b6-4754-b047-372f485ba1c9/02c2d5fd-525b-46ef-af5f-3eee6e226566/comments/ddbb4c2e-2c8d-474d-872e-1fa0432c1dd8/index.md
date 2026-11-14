---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:03:05Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:03:05Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
@anyone What should a lease write restamp and commit?

Options:
- A: Restamp `modified`. Never commit it alone, only with the holder's next commit.
- B: Restamp `modified`, and commit and push each lease write.
- C: Leave `modified` alone.
- Recap: Explain this in plain terms first

Recommended: A.
If no answer: A stands when the round closes.
Context: body.
