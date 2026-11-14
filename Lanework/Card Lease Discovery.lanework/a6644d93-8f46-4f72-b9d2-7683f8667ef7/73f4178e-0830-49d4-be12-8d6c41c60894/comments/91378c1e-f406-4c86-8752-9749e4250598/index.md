---
schema: 1
kind: comment
created:  {at: 2026-11-14T13:43:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:43:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
in-reply-to: 0c387804-d76a-44a1-b6ed-a76f07d2432b
---
**In plain terms: does a claim on a card have to stop two agents on different computers, or only two on the same computer?**

- **The setup today**: every agent session works in one folder on one Mac. When one agent claims a card, the others see the claim on disk at once.
- **A**: the lease only has to work on one computer. An agent on another computer sees the claim late, after a pull, so there it is only a hint. The card says so.
- **B**: the lease must also work across computers. Then every claim, and every renewal while working, becomes a commit pushed to the shared repo, and the first push wins. That is slower and adds git traffic.
- **What hangs on it**: how strict the later questions on staking and renewal have to be.
