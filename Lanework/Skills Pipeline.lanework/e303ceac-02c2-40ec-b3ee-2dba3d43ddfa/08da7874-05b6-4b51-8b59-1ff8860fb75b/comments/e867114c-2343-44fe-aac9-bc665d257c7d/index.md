---
schema: 1
kind: comment
created:  {at: 2026-09-27T20:54:30Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T20:54:30Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in 546c1cb.** Requested and scoped by the owner in chat, so triage and review happened there. Words: `SKILL.md` 2343 → 573; whole skill, scripts included, 8433 → 4872. Verified: `bash -n` on every script, then found, file Q1 and Q2 (with `--depends`), settle Q1 with a chat record and park Q2 on a scratch board, which the schema validator passed with 0 failures over 13 documents. Also checked: a title with a colon is quoted, and an unfilled `{{key}}` makes `render` fail loudly.
