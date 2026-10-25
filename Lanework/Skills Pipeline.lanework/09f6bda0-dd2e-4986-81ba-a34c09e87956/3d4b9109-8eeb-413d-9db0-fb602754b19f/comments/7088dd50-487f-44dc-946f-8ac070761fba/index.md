---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:44:09Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T10:44:09Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Filed straight into Active: the owner asked in chat to release 0.7.0, and the guide gate blocks it. The owner chose a drift pass first, then the release.**

- **Why Active, not Issues**: the owner's chat request is the go-ahead. The Active lane's one-card-per-session rule yields to it. [Dispatch](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f36f6a5d-32a5-498e-8b4c-276b2e4e80d4) stays here too, waiting on its trial.
- **Plan**: an opus fixer on branch `guide-v101` (worktree `.claude/worktrees/guide-v101`, off `origin/main` at `9a12b5d`). Then review, merge, and the 0.7.0 release with its changelog.
- **Rejected**: releasing on v93 from a clean checkout. That works around a gate the repo keeps on purpose.
