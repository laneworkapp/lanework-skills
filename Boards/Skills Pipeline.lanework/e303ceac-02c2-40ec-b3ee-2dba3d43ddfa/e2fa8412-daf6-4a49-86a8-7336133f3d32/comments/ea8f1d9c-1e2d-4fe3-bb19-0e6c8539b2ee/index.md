---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:09:30Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T01:09:30Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main: ADRs and PDRs are cards in a Decisions lane on each discovery board, filed by `file-record.sh` before the question settles. Nothing is written under `docs/adr/` or `docs/pdr/`.**

- **Commits**: `c949fd3` (lane, kinds, script, prose), `74dbb4c` (record order, script hardening), `34bcef0` (wording). Fast-forwarded onto main after a rebase over board-only commits.
- **Evidence**: `bash tests/smoke.sh` on main at `34bcef0` printed `smoke: 43 passed`, exit 0. The adversarial review approved in round 2 with 0 BLOCKING. The fixer's scratch round, in the new order, validated with 0 failures.
- **Done when, checked**: a fresh discovery board has Decisions at 4608. A ruling that clears the bar yields a card there, linked both ways with its question (smoke case 25). No `docs/` write.
- **Different from the body**: a record is filed before `settle-question.sh`, ruled by the lead in round 1. `file-record.sh` also refuses a question not in Asked.
- **Split out**: the `file-question.sh` backslash bug and the `model: unknown` default, as [4ff216a4](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03) in Issues.
- **Ships**: with the next release. No changelog entry until then.
