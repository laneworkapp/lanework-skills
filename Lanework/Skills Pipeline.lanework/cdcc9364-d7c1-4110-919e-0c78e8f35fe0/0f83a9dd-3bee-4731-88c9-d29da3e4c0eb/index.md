---
schema: 1
kind: card
title: "lanework: a lease script to stake, renew, check and release a card lease"
order: 3072
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Add one script to the `lanework` skill that holds the whole card lease: stake, renew, check, release and list, with the background timer, the clock guard and the takeover notice, as settled on the Card Lease Discovery board.

## Files

- `skills/lanework/scripts/lease.sh`: new. Subcommands `stake`, `renew`, `check`, `release [--force]`, `list <board>`. The name may change in shaping.
- `skills/lanework/scripts/lib.sh`: shared helpers only if a second script needs them.
- `skills/lanework/references/writes.md`: one section on the lease, the one place the rules are stated.
- `skills/lanework/SKILL.md`: one row pointing at it.
- `tests/smoke.sh`: the cases below.
- `README.md`, `CHANGELOG.md`: the key-features list and one user-facing entry, at release.

## Behavior

- **Shape**: `claimed: {by, until}` in card frontmatter. `by` is the stamp's `by` with `session` required, read from `CLAUDE_CODE_SESSION_ID`. No session id, no lease.
- **Stake**: write, wait a second, read back. Another `by` means back off. A valid lease held by another session is refused.
- **Timer**: a background loop started by `stake`. Each minute it reads the card for a takeover notice, every 15 minutes of elapsed time it renews, and it exits when its session's process is gone or the lease is no longer its own.
- **Renew**: reads `by` first. Another session's `by` means stop and post the "lease lost" record, in one fixed wording, naming the work in flight. Lapsed and still its own means renew.
- **Clock guard**: `until` over 35 minutes ahead of now is no lease. Whoever stakes over one records that.
- **Takeover**: for a lapsed lease, post the takeover record as a notice, wait two minutes, read again. Renewed means back off. Unchanged means stake.
- **Release**: delete `claimed`, stop the timer. `--force` releases another session's lease on the owner's word and records it.
- **Every lease write** restamps `modified` and makes no commit.
- **List**: one line per held card: title, holder, time left, lapsed or not.

## Verified

- `tests/smoke.sh` passes, with new cases on throwaway boards: two racing stakes leave one holder; renewal moves `until`; a changed `by` yields the "lease lost" record and no further write; the clock guard voids a far-future `until`; a takeover waits and backs off when the holder renews, and stakes when it does not; release and forced release; the timer exits when its session's pid is gone; a merge of two differing leases keeps the later `modified`.
- One manual check, quoted in the closing comment: a card open in the Lanework app while a lease is staked and renewed, to see whether the app writes back an older copy. A failure becomes a request to the app.
- Scripts target macOS bash and BSD tools.

## Done when

`lease.sh` exists, every behavior above has a smoke case that failed before and passes after, `writes.md` states the rules once, and the app check is recorded.

## Depends on

- [Skills target agent guide v117](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8): smoke is red at the stamp gate until it lands.

## Source

- [ADR: A lease's holder is the stamp's by, with the harness session id required](lanework://33527992-d72c-417b-85a2-1b62bea96794/31f5a0e4-1c31-43be-a36f-5fedd78a3bc9)
- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: A lease holds on one machine; across machines it is a hint](lanework://33527992-d72c-417b-85a2-1b62bea96794/94e3d45e-37cf-4c39-a633-87610ab297b4)
- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
- [ADR: A lease runs 30 minutes, renewed by a timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/ce03dec0-06e0-4fa8-ac29-671c59ba6930)
- [ADR: A lost lease leaves the work in place, and the loser stops](lanework://33527992-d72c-417b-85a2-1b62bea96794/3b8d6e0b-1668-4e67-80ab-4a88fda8ad96)
- [ADR: A takeover posts a notice and waits two minutes](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b)
- [ADR: The clock guard is a range check against now, with an elapsed-time timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/674f3c98-33a5-41f5-acb3-7f59abafdfcf)
- [ADR: One lanework script holds the lease mechanism and its timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/0e5b4553-6ac0-47b9-862b-91951dc35948)
- [ADR: A lease write restamps modified and is never committed alone](lanework://33527992-d72c-417b-85a2-1b62bea96794/aec193e9-55d2-4f60-9cd6-17a05258e307)
