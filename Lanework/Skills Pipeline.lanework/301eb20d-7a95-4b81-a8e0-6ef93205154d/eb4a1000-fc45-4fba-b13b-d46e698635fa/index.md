---
schema: 1
kind: card
title: "work: card-writing scripts check the lease, and START shrinks to a short plan"
order: 5120
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:58:58Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
Make the `work` skill honor the card lease: `post-comment.sh` checks the lease before it writes, the session that works a card stakes it before starting and releases it in its closing write, and the START comment shrinks to a short plan that is no longer a claim.

## Files

Only `work` files change. The lease script itself (`skills/lanework/scripts/lease.sh`, its rules in `lanework/references/writes.md`) is the lease card's.

- `skills/work/scripts/post-comment.sh`:
  - Before the final `mv`, call `lanework/scripts/lease.sh check <board> <card>`, with the session id read from `CLAUDE_CODE_SESSION_ID`, never from `--session` (that flag is a free label in comment stamps, not the lease's holder id).
  - Outcome 0 (no lease, a lease this session never held, no session id in the environment, or a held or lapsed-but-own lease, renewed with its timer restarted by the check): write as today.
  - Outcome lost (another session's `by`): the lease script posts the fixed-wording "lease lost" record itself, so the check does not recurse into this script. `post-comment.sh` writes nothing of its own, prints the reason on stderr and exits 3. A later call from the loser finds the record already there and writes nothing.
  - New flag `--release`: after the comment lands, `lease.sh release <board> <card>`. This is the "in its closing write" of the release ruling. It releases nothing on a lost lease.
  - Header comment gains exit 3 and `--release`. `--ahead`, the lint and the same-second check are unchanged.
- `skills/work/references/writing.md`: a new section, START, the one place its shape lives: `START: <the plan in one line>`, then at most Scope, Verify and Where, about 40 words. A choice made while planning goes to its own record, as this file already asks. Line 19 (no handle in START) stays.
- `skills/work/references/companions.md`: line 5 stops reading a START as a claim. The lease is the claim: a card with a live lease from another session is theirs, a lapsed one is taken over as `lanework/references/writes.md` says (notice, two minutes), and across machines a lease is only a hint. Rules link, nothing restated.
- `skills/work/references/lead.md`: the lead is the session. It stakes each card at dispatch, before the fixer is handed the worktree, and releases it when the card closes, with `post-comment.sh --release` on the closing record. The cycle diagram gains both steps.
- `skills/work/references/fixer.md` § 1: "Post START before coding: the journal entry and the claim" becomes "Post START (`writing.md` § START) before coding". A fixer never stakes: its lead's session holds the lease (the session-holds ruling, linked below).
- `skills/work/references/team.md`: the sentence "Only the lead runs `git worktree`, grants slots, merges, moves cards and mentions the human" gains "stakes and releases leases".
- `skills/work/references/sweep.md`: § Farm: the farming session stakes each card before it farms it. § Triage report: a line listing held cards (`lease.sh list <board>`) and flagging a lapsed lease, and the "Approved, unstarted" and "Active, stalled" rows read the lease, not a START.
- `skills/work/templates/farmed-prompt.md`: a `Lease:` line naming the lease the sender's session holds on the card, and "never run the lease script to stake: your writes pass its check under the session's id".
- `tests/smoke.sh`: the cases below, after the existing post-comment cases (line 681 on).

Not touched: `lib.sh` (no second caller yet), `README.md` (no key feature of its own; the lease card adds the line), `plugin.json`, the other scripts under `skills/work/scripts/`. `CHANGELOG.md` gets one user-facing entry at release, shared with the lease card.

## Verified

`tests/smoke.sh` passes, new cases named by what they prove, all on a throwaway copy of the discovery fixture (never this board), with `CLAUDE_CODE_SESSION_ID` set per case and every staked lease and timer released in a trap:

1. `post-comment.sh` on a card the caller holds writes the comment and leaves `claimed` as it was.
2. On a lapsed lease still the caller's, it renews (`until` moves forward, a timer is running again) and writes.
3. On a lease carrying another session's `by`, after the caller held it: exit 3, only the "lease lost" record lands, the requested body is absent, and a second call writes nothing at all.
4. On a card with no lease, on a lease held by another session that the caller never held, and with no session id in the environment: writes as today (the existing cases at line 681 on pass unchanged).
5. A subagent: same session id, `--name fixer`, writes under the lead's lease.
6. `--session "some label"` does not change the outcome: the check uses the environment id.
7. `--release`: the comment lands, then `claimed` is gone and the timer has exited. On a lost lease it releases nothing.
8. `post-comment.sh` stays a refusing no-op on every existing refusal (bad body, same second, two cards with one uuid): nothing written, lease untouched.
9. Prose gates by grep: no file under `skills/work/` says a START is a claim; `writing.md` has the one START section; `farmed-prompt.md` carries the `Lease:` line; `fixer.md` says a fixer never stakes.

`tests/check-refs.sh` covers the new cross-skill cites (`lanework/scripts/lease.sh`, `lanework/references/writes.md`), and `bash -n` covers the script. Prose read through against `lanework-agent-guide` v117.

## Done when

- `post-comment.sh` passes cases 1 to 8, and `tests/smoke.sh` is green.
- The seven reference and template files above carry the change, and no file under `skills/work/` calls a START a claim.
- START has one definition (`writing.md` § START), and `companions.md`, `fixer.md` and `lead.md` link to it.
- The lead stakes before dispatch and releases on closing, in `lead.md`; the farmed prompt tells a subagent not to stake.

## Risks

- **Blocked by the lease script.** `check` must return three outcomes (write; lost, with the record already posted; and "not this session's card"), and it must know which cards its session staked, since a lease carrying another `by` blocks only a session that held it (answers on other people's cards stay open). Confirm both on [0f83a9dd](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb) before building. Also: compare the session id, not `by.name`, so a fixer under the lead's lease passes.
- **Hand-rolled writes skip the check.** Only `post-comment.sh` checks today. That is the accepted limit of the check-in-the-script ruling.
- **Other START readers.** `dispatch/scripts/arm-pass.sh` reads a START as a claim and goes stale 30 minutes after it; still works, as START keeps its `START` prefix. It, `watch`, `plan`, `lanework/templates/pipeline-lanes.md` and `heal/scripts/heal-descriptors.py` still describe START as the claim. They are other skills' cards, not this one.
- **The 50-card trial** (a script scanning threads for two STARTs) needs the `START:` prefix kept as the first word of the comment. This card keeps it.
- **A farmed agent whose environment lacks the session id** holds nothing, so its writes pass as today and nothing stops it on a lost lease. Smoke case 4 pins that.
- Scripts target macOS bash and BSD tools.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb): `lease.sh` with `check`, `release` and `list`. This card builds on it.
- [Work skill: ship move-card, post-ask and commit-board helpers](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f): `move-card.sh` and `post-ask.sh` gain the same check when they exist. `post-ask.sh` wraps `post-comment.sh`, so it inherits the check. `move-card.sh` calls `lease.sh check` itself, added by whichever card builds second.
- [Skills target agent guide v117](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8): smoke is red at the stamp gate until it lands.

## Recommendation

Build as written, after the lease script. Minor bump (new behavior). No open calls: every behavior is a ruling on the Card Lease Discovery board, linked below.

## Source

- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
- [ADR: Every card-writing script checks the lease first](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)
- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: A lost lease leaves the work in place, and the loser stops](lanework://33527992-d72c-417b-85a2-1b62bea96794/3b8d6e0b-1668-4e67-80ab-4a88fda8ad96)
- [PDR: Leases are seen through agents and reports, not on the board](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)
- [PDR: The lease works when smoke passes and 50 leased cards run clean](lanework://33527992-d72c-417b-85a2-1b62bea96794/67912ed8-4595-4514-8a6f-a5a629b473c8)
