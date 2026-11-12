---
schema: 1
kind: comment
created: {at: 2026-11-12T00:47:26Z, by: {name: shaper, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Shaping: re-scoping this card from guide v107 to the board's guide as it stands now (v114), as the catch-up that unblocks 0.8.0.**

Plan: diff the guide from the last committed copy (v101, `9a12b5d`) to the working tree (v114), using Board Runner Discovery's working-tree guide (v107) to split v101 to v107 from v107 to v114. Check `.schema/` (VERSION, HEAL.md, heal, validator, the JSON schemas). Map each change to a skill file and line or to nothing, then list the fixtures to re-copy. No build.
