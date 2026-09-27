---
schema: 1
kind: comment
created:  {at: 2026-09-27T20:40:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T20:40:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in 2ca828a (move), c44a2f5 (board) and 6a1c204 (CLAUDE.md), filed after the fact.** Verified: the `discovery` to `pitlane` lint path still resolves from `skills/`, `plugin.json` parses, and all 8 board files parse as YAML under PyYAML 6. No schema validator was on the machine, so the app's first open is the remaining check.
