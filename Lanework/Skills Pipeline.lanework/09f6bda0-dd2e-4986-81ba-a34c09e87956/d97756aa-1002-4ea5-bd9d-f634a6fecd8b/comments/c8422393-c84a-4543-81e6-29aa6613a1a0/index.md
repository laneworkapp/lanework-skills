---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:51:28Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T11:51:28Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Lead ruling on the fixer's divergence: a duplicate kind within one list still exits 2. A kind repeated across `--labels` flags is written once.**

- **Why the spec was wrong**: it said `SEEN` already dedupes. It refuses instead, and an existing smoke case asserts the refusal.
- **Decided**: keep the refusal. `type,type` in one flag is most likely a typo. Repeating across flags is composition, which this card exists to allow.
- **Rejected**: silent dedupe everywhere. It would flip a shipped, tested behaviour for no caller that needs it.
