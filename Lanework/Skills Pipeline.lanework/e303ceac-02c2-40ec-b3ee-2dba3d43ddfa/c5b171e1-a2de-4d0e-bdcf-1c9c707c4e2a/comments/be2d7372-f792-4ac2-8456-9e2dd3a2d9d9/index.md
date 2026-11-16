---
schema: 1
kind: comment
in-reply-to: e7c4a842-4a44-47a0-acb1-ade05ef3ffed
created:  {at: 2026-11-16T01:13:36Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-16T01:13:36Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Closed: 0.8.0 is released and carries the switch to the central marketplace.**
- **Released**: `v0.8.0`, cut on the owner's word in chat ("cut it"); `stable`, `main` and the tag all at `a1e671b`. Cut from a fresh clone, where smoke passes, since the main checkout fails the guide-version gate.
- **Done-when, checked on `origin/stable`**: `grep -n "lanework-skills.git" README.md` finds only line 168, the manual-install clone. README line 159 names `lanework-marketplace.git`. The GitHub release notes carry the three switch-over commands.
- **Not checked**: the CI run on `stable` was still in progress, and is expected red per [CI smoke fails on every push](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/bf23391d-93bd-43ba-a848-2e998c767905).
- **Next**: [Remove this repo's own marketplace.json](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7) is unblocked and rides the release after this one, as ruled.
