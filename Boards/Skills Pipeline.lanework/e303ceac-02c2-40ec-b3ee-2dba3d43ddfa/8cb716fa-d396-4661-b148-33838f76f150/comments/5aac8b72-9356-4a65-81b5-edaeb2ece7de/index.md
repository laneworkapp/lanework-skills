---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:58:09Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T02:58:09Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
**Done on the owner's go-ahead in chat: the repo stamp reads `lanework-agent-guide v83` at `fa797dd`, and smoke is green on main.**

- **Evidence**: `tests/smoke.sh` on main after the bump: `smoke: 65 passed`, the stamp gate included.
- **Drift check**: the v83 diff adds only `group: {by: label, kind: …}`. A grep of `skills/` for `group` finds two mentions, `founding.md:22` (cites the guide) and `board-kinds.md:25` (`by: modified`). Both are still correct.
- **Committed alongside**: the app's v83 rewrite of this board's `CLAUDE.md` and `AGENTS.md`, byte-identical twins.
