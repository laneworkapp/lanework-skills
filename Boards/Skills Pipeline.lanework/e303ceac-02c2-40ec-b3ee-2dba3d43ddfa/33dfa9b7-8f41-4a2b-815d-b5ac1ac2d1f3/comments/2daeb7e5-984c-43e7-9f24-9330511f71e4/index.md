---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:50:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:50:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: build plan dependencies as depends-on relations.**

- **Scope**: `lib.sh` relation helpers, new `plan/scripts/deps.sh`, `file-ticket.sh`, `frontier.sh`, `resolve-ticket.sh`, `file-record.sh`, plan references and templates, smoke cases, README sizes.
- **Verify**: smoke cases 1 to 8 of the body; full `tests/smoke.sh`; a separate reviewer.
- **Where**: branch `feat/33dfa9b7-plan-relations`, worktree `.t/33d`.
