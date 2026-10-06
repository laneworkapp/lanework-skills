---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:41:56Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:41:56Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Found by the pointer-audit fixer and confirmed on main at `3908fde`. It blocks every merge in the current campaign, so it builds first.**

**Rejected**: dropping `--strict`. That would also hide every other manifest warning.
**Rejected**: moving `CLAUDE.md`. Claude Code reads it from the repo root.
