---
schema: 1
kind: comment
created:  {at: 2026-09-29T16:14:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-29T16:14:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in `e105e7f`. The only drift from v75 to v77 was tracker handling.**

- **Found**: v75's skills told agents they may hand-write a board's `remote` and a lane's `remote-state`. The v77 release guide says never write any tracker key and never add a `remote` to bind a board.
- **Decided**: the rule keys off the board's own guide text ("This build runs no tracker engine"), not the version number. Both variants carry v77, so the number can't tell them apart.
- **Evidence**: the Lanework app's `AgentGuide.swift` diffed from v75 (`cdd6d85f7`) to v77 (`4653de300`). Every change outside tracker text is the v76 rename. `tests/smoke.sh`: 17 passed, stamp v77. README sizes recounted.
