---
schema: 1
kind: comment
created:  {at: 2026-09-28T09:57:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T09:57:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Started: the owner asked for this in chat, so triage and review happened there.**

- **Plan**: diff `AgentGuide.swift` from the v70 commit (28b1cb04b) to HEAD, read each skill against it, fix only drift, then bump the stamp and run smoke.
- **Not in scope**: dropping the runtime version check, which is its own Ideas card, [4a97bc2b](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4a97bc2b-2950-4522-9a1b-03e64511ac77).
