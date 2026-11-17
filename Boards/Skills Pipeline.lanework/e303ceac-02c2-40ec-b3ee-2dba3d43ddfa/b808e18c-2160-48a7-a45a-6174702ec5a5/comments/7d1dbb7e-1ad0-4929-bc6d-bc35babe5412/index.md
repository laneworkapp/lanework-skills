---
schema: 1
kind: comment
created:  {at: 2026-11-17T19:09:50Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this card as lead, second of the cards that call the lease script.**

- **Scope**: `plan`'s `claim-ticket.sh` and `resolve-ticket.sh` stake, check and release through `lanework/scripts/lease.sh`; the `plan` references and smoke follow.
- **Verify**: `tests/smoke.sh`, 216 on main today.
- **Where**: branch `plan-lease`, worktree `.claude/worktrees/plan-lease`, cut from main at `f3f0c75`.
- **Order**: [the lease trial card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b) sits higher in Approved and builds after the cards that call the script.
- **Lead's ruling, the session id**: the lease's holder is `CLAUDE_CODE_SESSION_ID` only. The body says `--session` "becomes the lease's session id when given"; the lease script as built takes the holder from the environment and never from a flag, as [the holder ruling](lanework://33527992-d72c-417b-85a2-1b62bea96794/31f5a0e4-1c31-43be-a36f-5fedd78a3bc9) says, and the body's Risks say its calls follow the lease script where that card shaped things differently. So `--session` stays the label in stamps. A claim with no session id in the environment, or with no `CLAUDE_PID` (the script refuses to stake without the session's process), exits 1 with nothing written. A hand-run claim outside Claude Code therefore cannot claim.
- **The lease script as built**, where the body guessed:
  - `stake` exits 1 refused, 2 no session id or process, 3 lost; `check` exits 0 held, 3 lost, 4 never held. `resolve-ticket.sh` treats 4 as "resolves as today" and 3 as refused.
  - The takeover notice and the stake's read-back wait can be shortened in tests, so the lapsed-takeover case runs in smoke.
  - The script's memory is per board folder, and it finds the card by uuid at every call.
- **Team**: one fixer on the higher tier (a claim race and timers in tests), then an adversarial reviewer.
- **CHANGELOG**: at release, with the other lease entries.
