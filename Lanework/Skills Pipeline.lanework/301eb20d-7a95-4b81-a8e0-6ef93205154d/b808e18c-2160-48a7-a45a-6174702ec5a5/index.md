---
schema: 1
kind: card
title: "plan: claim-ticket stakes a lease and still moves the ticket to Working"
order: 7168
labels: [{text: plan, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:59:28Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
Make `plan`'s `claim-ticket.sh` and `resolve-ticket.sh` stake and release a card lease through the lanework lease script, with claiming still moving the ticket from Frontier to Working, so the lane shows the stage and the lease shows the holder.

## Files

- `skills/plan/scripts/claim-ticket.sh`: after the Frontier check and before any staging, run the lease script's `stake` on the card, still in Frontier. A refused or lost stake exits 1 with the holder named and writes nothing else. Build the restamped copy only after the stake lands, so the staged file carries `claimed` and the move cannot overwrite it with an older copy. The move, the fresh `order`, the whole `modified` and the `**Claimed** by` comment stay as they are. If the card left Frontier after the stake, or a later step aborts, release the lease it just staked. No session id (neither `--session` nor `CLAUDE_CODE_SESSION_ID`) exits 1 with nothing written: no id, no lease. `--session` keeps its meaning and becomes the lease's session id when given. Header comment updated.
- `skills/plan/scripts/resolve-ticket.sh`: before writing, run the lease script's `check` on the card; another session's lease means exit 1, nothing written, and the check posts the "lease lost" record. A card with no lease (a ticket claimed before this change, or one never held) resolves as today. `restamp()` drops `claimed` together with `waiting`, in the same awk pass and so in the same write as the move, block-form lines included. After the card lands, run the lease script's `release` once to stop the timer. Applies to `--to resolved` and `--to out-of-scope` from Working.
- `skills/plan/references/tickets.md`: § Claim states the lease (stake first, then move, one holder) and the one-machine limit, where a lease across machines is only a hint. Says a HITL ticket left waiting in Working has its lease released, and that resuming one stakes again with `lease.sh stake`, no move. § Resolve says the resolution write releases.
- `skills/plan/references/sessions.md`: Work step 2 (a named Working ticket is resumed by staking, not by claiming), step 3 (a ticket left waiting on the owner is released before the session stops), step 4 (resolve releases). Chart step 6: the session claims each Research ticket before dispatching, the subagent resolves its ticket under the session's lease and never stakes; its prompt names the lease.
- `skills/plan/references/board.md`: the Frontier to Working row of the Moves table says the claim also stakes a lease.
- `skills/plan/SKILL.md`: the two Scripts rows say it.
- `README.md`: the § Sizes rows for each changed file under `plan` (word counts match `wc -w`, which `tests/check-sizes.sh` enforces).
- `tests/smoke.sh`: the cases below, and `CLAUDE_CODE_SESSION_ID` exported for the existing plan claim, resolve and record cases (they claim with no session id today).

Not touched: `frontier.sh` (a held or lapsed Working ticket is read with the lease script's `list`), `templates/`, the lane policy text, and everything under `skills/lanework/` (the other card). `CHANGELOG.md` takes its user-facing entry at release, written once for the lease.

## Decided in shaping

- **Order**: stake in Frontier, then move. A stake after the move would leave a window where a Working ticket has no holder.
- **The `Claimed` comment stays**. `plan` writes no START comment, so there is nothing to shrink; the comment is the record of the move.
- **Resume and release call the lease script directly**: `claim-ticket.sh` stays Frontier-only, so there is no `--resume` flag.
- **A subagent's `resolve-ticket.sh` call is the closing write**, so it releases the session's lease for that ticket, and the session never stakes twice.

## Verified

`tests/smoke.sh` passes with these new cases, each failing before the change:

- `plan claim stakes a lease and moves to Working`: with `CLAUDE_CODE_SESSION_ID` set, the ticket is in Working, `claimed.by.session` is that id, `until` is about 30 minutes ahead, the `Claimed` comment exists, the board validates.
- `plan claim backs off a Frontier ticket another session holds`: the ticket stays in Frontier, no comment, the other session's lease is untouched, exit 1.
- `plan claim race leaves one holder`: two claims of one Frontier ticket from two session ids at once give one exit 0, one exit 1, one `Claimed` comment, and a lease naming the winner.
- `plan claim without a session id writes nothing`: the board checksum is unchanged, exit 1.
- `plan resolve releases the lease`: after a claim and a resolve, the card in Resolved has no `claimed` key, in compact and in block form, `waiting` is still dropped, and the timer is stopped.
- `plan resolve refuses another session's lease`: ticket stays Working, nothing written. A Working ticket with no lease still resolves.
- `plan out-of-scope from Working releases the lease`.
- `plan resume stakes a Working ticket without moving it`: refused while the holder's lease is valid; staked after a release. Taking over a lapsed lease waits two minutes (the notice), so that path is run in smoke only if the lease script offers a way to shorten the wait; otherwise it is run once by hand and quoted in the closing comment.
- Every case releases what it stakes, so no timer outlives smoke.

Also: `bash -n` on both scripts, and `tests/check-refs.sh` and `tests/check-sizes.sh` through smoke. Scripts target macOS bash and BSD tools. Never run against the Skills Pipeline board.

## Done when

- Both scripts go through the lease script and write no `claimed` themselves.
- Every case above exists and passes, and `tests/smoke.sh` is green.
- The `plan` references say once that a claim stakes a lease and moves the ticket, that a ticket left waiting is released, that resuming stakes again, and that across machines a lease is a hint.
- A Working ticket whose session died can be taken once its lease lapses, and not before.

## Risks

- **This card cannot be built before the lease script lands.** It calls `stake`, `check` and `release`, and `tests/check-refs.sh` fails on a cited file that does not exist. The calls here assume `<board> <card-uuid>` arguments, the session from `CLAUDE_CODE_SESSION_ID`, a non-zero exit for each refusal, and lookup of the card by uuid at every call, because the card moves lanes under the timer. If the other card shapes this differently, the calls here follow it.
- **The takeover notice costs two minutes**, so a smoke case on it is slow unless the lease script gives a test override.
- **Staking is provisional** ([ADR](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)): a collision is found at renewal, and the first "lease lost" record reopens the ruling. Plan tickets count toward the 50-card trial.
- **A plan session with no session id can no longer claim.** Claude Code sets one, so it only affects a hand-run claim outside it, which then passes `--session`.
- **Every plan smoke case that claims gains a one-second wait** from the read-back.
- **Parallel Research tickets** mean one session holds several leases at once, one timer each. The lease script must handle that.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)
- [Skills target agent guide v117](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8): smoke is red at the stamp gate until it lands.

## Recommendation

Build it, after the lease script: a small, mechanical change, since every rule is already ruled. No open call remains.

## Source

- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
- [Q10: plan's Working lane beside the lease](lanework://33527992-d72c-417b-85a2-1b62bea96794/65be9ca2-633e-4ec9-8591-ff7ff12adea7)
- [Q8: Releasing a lease](lanework://33527992-d72c-417b-85a2-1b62bea96794/0f36b65c-b027-461a-b9af-5c8db6e5fc5a): released in the closing write
- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: Every card-writing script checks the lease first](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)
- [ADR: A lease holds on one machine; across machines it is a hint](lanework://33527992-d72c-417b-85a2-1b62bea96794/94e3d45e-37cf-4c39-a633-87610ab297b4)
- [ADR: A lease's holder is the stamp's by, with the harness session id required](lanework://33527992-d72c-417b-85a2-1b62bea96794/31f5a0e4-1c31-43be-a36f-5fedd78a3bc9)
