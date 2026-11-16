---
schema: 1
kind: comment
in-reply-to: e7c4a842-4a44-47a0-acb1-ade05ef3ffed
created:  {at: 2026-11-16T00:38:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-16T00:38:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Ruled in chat 2026-11-16: 0.8.0 no longer waits on the dispatch trial.**
- **Owner's words**: "i'm okay postponing dispatch skill (whatever we were planning to do with it) until after 0.8"
- **Read as** (the agent's reading): the ask above now reads "cut 0.8.0, then reply here". Cutting the release stays the owner's call.
- **Still in the way of the cut**: `CHANGELOG.md` had no `Version 0.8.0: ` entry, and smoke fails in the main checkout at the guide-version gate (board guide v118, stamp v114) while passing 157 cases in a clean checkout of `6215155`.
