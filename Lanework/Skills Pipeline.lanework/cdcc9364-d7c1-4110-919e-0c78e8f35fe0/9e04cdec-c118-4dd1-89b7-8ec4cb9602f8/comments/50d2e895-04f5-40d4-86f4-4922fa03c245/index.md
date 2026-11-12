---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:57:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Filed when the watch saw the app rewrite this board's guide to v117, mid-way through the 0.8.0 builds.**

- **Evidence**: `head -1` of the working-tree `CLAUDE.md` reads `lanework-agent-guide v117`; HEAD's reads v114 (committed as bfb5f14). `.schema/bin/lanework-validate.py` moved v4 to v5 in the same rewrite. `AGENTS.md` moved with it.
- **Effect**: smoke was green in the main checkout at 2dc7b75 and fails there again at the stamp gate. It stays green in a clean worktree, where the committed guide is v114.
- **Previous catch-up**: [guide v114 card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2c29a34f-fde2-4a44-8a3b-94157a320609), landed 2dc7b75.
- **Not decided here**: whether 0.8.0 waits for this card. That is the owner's call.
