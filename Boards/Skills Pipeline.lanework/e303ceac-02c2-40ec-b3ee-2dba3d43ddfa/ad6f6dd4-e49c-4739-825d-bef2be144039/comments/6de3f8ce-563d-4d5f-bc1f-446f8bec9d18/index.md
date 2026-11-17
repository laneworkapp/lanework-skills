---
schema: 1
kind: comment
created:  {at: 2026-09-28T10:14:27Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T10:14:27Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Approved by the owner in chat and started at once. Claimed by this session, working on `main`.**

- **Why now**: the only installed copy today is the owner's own symlink. Once [the marketplace card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/05809e25-fb9d-42de-b1af-22ec34fc227a) ships, a rename breaks other users' installs too.
- **Accepted limitation**: the plugin namespaces it as `lanework:lanework`. The model triggers it, so users rarely type that.
- **Found**: the app guide's skills paragraph (line 15 of v70) is already out of date. It names the repo `laneworkapp/skills`, lists three skills, and says pitwall watches one board. It's app source, so the fix goes on the app's board.
- **Plan**: the repo rename goes to a sonnet subagent. This session reviews the diff and handles the board relabel and the local link.
