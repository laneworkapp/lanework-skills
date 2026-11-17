---
schema: 1
kind: comment
in-reply-to: 7dbd7091-4820-44be-a05a-1a3576dc8cc7
created:  {at: 2026-11-17T21:23:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: merged to main at `18ab58f`, smoke green. Not released.**

- **Merge**: branch `plan-lease` at `4503c85` (commits `0ec7fd6`, `94d2e36`, `94c5f78`, `a092a90`, `2dd4a18`, `4503c85`), merged with `--no-ff` as `18ab58f` and pushed.
- **Gate**: `tests/smoke.sh` on main after the merge, with the session variables unset: `smoke: 229 passed`, exit 0. Main before was 216; this card adds 13 cases. No lease timer left running.
- **Review**: adversarial, four passes. Round 1 asked for changes, round 2 approved with notes, the re-check of the ruled fixes asked for changes, the last re-check approved at `4503c85`. That is one pass more than the build cycle allows, by the lead's ruling above.
- **Done-when**:
  - Both scripts go through the lease script and write no `claimed` themselves. Met.
  - Every case in the body exists and passes, the lapsed takeover included, and smoke is green. Met.
  - The `plan` references say once that a claim stakes a lease and moves the ticket, that a ticket left waiting is released, that resuming stakes again, and that across machines a lease is a hint. Met.
  - A Working ticket whose session died can be taken once its lease lapses, and not before. Met, in smoke.
- **Departures from the body**, each by a ruling or a recorded decision on this thread:
  - The lease's holder is the environment's session id only; `--session` stays a stamp label. A claim with no session id or no session process exits 1.
  - `resolve-ticket.sh` refuses a ticket carrying another session's lease, live or lapsed, that this session never held: stake first.
  - A claim ended by a signal releases its stake unless its own move has put the card in Working, where it keeps the lease.
- **Left open**, filed on [the lease issue](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/653217e4-681e-44f5-b6eb-fb0d0b8490ca): the timer's start order, the renewal race on resolve, the restamped Frontier ticket, the one-fork window, the uncatchable signal, and the smoke case that fails under parallel load.
- **Not done here**: this card was worked without a lease staked on it by the lead.
- **CHANGELOG**, for the release commit: "Claiming a plan ticket now takes a lease on it, so two sessions can't work the same ticket, and resolving it lets the lease go."
- **Next**: the watch card in Approved.
