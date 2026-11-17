---
schema: 1
kind: comment
created:  {at: 2026-11-17T19:24:27Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T19:24:27Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Built and green: `tests/smoke.sh` ends `smoke: 225 passed`, 216 on main plus 9 new; pushed `plan-lease` at `94d2e36`.**

- **Decided, exits**: claim exits 1 for every refusal (no `CLAUDE_CODE_SESSION_ID`, no `CLAUDE_PID`, no `lease.sh`, stake exit 1, 2 or 3). Resolve exits 1 on a lost lease (check 3), as the body says, not 3 as `work`'s scripts do.
- **Decided, never held**: `lease.sh check` returns 4 for another session's lease too. Resolve then reads `lease.sh list`: live or lapsed → exit 1, nothing written, "stake it first"; none or voided → resolves. Without this, resolve would drop another session's live `claimed`.
- **Decided, release after the drop**: `release` with `claimed` already gone finds no lease, stops the timer, removes the memory, writes nothing, exit 0. Measured in P5, P7, P8: zero Lease lost records, timer dead, memory gone.
- **Decided, claim trap**: an EXIT trap releases the stake unless the move landed, or the session held the card before the claim (read from `lease.sh list`). A `lease.sh check` just before the `mv` refuses a lease lost meanwhile.
- **Decided**: unblock's restamp keeps `claimed`; only the resolved card drops it.
- **Evidence**: 225 over 225; `pgrep -fl lease.sh` empty after the run. The test knobs ran the lapsed takeover in smoke (P8).
- **Attached**: `plan-lease-smoke.log`.
