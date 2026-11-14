---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:59:27Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:59:27Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Shaped: no open call, every behavior is a ruling; two derived decisions and one interface need recorded here.**

- **Decided**: stake in Frontier, then move ([Q3](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb) kept the lease off lanes, [Q10](lanework://33527992-d72c-417b-85a2-1b62bea96794/65be9ca2-633e-4ec9-8591-ff7ff12adea7) kept the lane). The restamped copy is built after the stake, since `claim-ticket.sh` stages a copy outside the board and moves it over the card: staged before, it would overwrite `claimed`.
- **Decided**: a ticket left waiting on the owner is released, per [Q8](lanework://33527992-d72c-417b-85a2-1b62bea96794/0f36b65c-b027-461a-b9af-5c8db6e5fc5a) ("done, handed to a human gate, or given up"). Resuming it stakes again. Without this a waiting ticket would show a lapsed lease after its session ends.
- **Decided**: a subagent's `resolve-ticket.sh` call releases the session's lease, as the closing write, after [ADR6](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118): Research tickets are dispatched to subagents that resolve their own ticket.
- **Rejected**: a `--resume` flag on `claim-ticket.sh` (the lease script already stakes a Working card); `frontier.sh` showing lease state (`lease.sh list` is the report, [PDR1](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)); changing lane or template text (the lease is not drawn on the board).
- **Evidence**: `claim-ticket.sh` stages a copy and `mv`s it over the card, so a stake before staging is required. `tests/smoke.sh` plan cases claim with no session id today, so they need `CLAUDE_CODE_SESSION_ID`. The README § Sizes word counts for `plan` change with the references.
- **Interface needed from the lease script card** (read only, not edited): lookup by card uuid on every call, because the card moves lanes under the timer; a distinct non-zero exit for no session id, a held card and a lost read-back; several leases and timers in one session; a test override for the two-minute takeover wait.
