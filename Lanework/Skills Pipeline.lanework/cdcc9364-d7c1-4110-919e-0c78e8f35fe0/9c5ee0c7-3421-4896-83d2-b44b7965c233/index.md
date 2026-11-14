---
schema: 1
kind: card
title: "watch and dispatch: the session stakes a lease before working or handing off a card"
order: 5120
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Make `watch` and `dispatch` honor the card lease: the session stakes a lease on a card before it works it or hands it to a subagent, keeps it while the subagent runs, and releases it after, and their arming reports list held cards.

## Files

- `skills/watch/references/arming.md`, `responding.md`: an unclaimed card is one with no valid lease. Stake before acting on a move or an arming work order; release when the card is handed to a gate or done.
- `skills/dispatch/references/routing.md`, `handler.md`: the session stakes before spawning a handler and releases when it reports back. The handler prompt names the lease and tells the handler not to stake.
- `skills/dispatch/scripts/arm-pass.sh`: `arm` skips a card with a valid lease. `stale` reads a lapsed lease, in place of a START with 30 minutes of silence.
- `skills/dispatch/scripts/state.sh`: the in-flight claim follows the lease, if both are still needed. Shaping decides.
- `tests/smoke.sh`: the `arm-pass.sh` cases.

## Verified

- `tests/smoke.sh` passes, with `arm-pass.sh` cases on a throwaway board: a card with a valid lease is not an `arm`; a card with a lapsed lease is reported; a card with no lease in an agent lane is an `arm`.
- Prose read through against the board guide.

## Done when

Both skills stake and release through the lease script, `arm-pass.sh` reads leases, the arming report lists held cards, and smoke is green.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)
- [work: card-writing scripts check the lease, and START shrinks to a short plan](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa): the farmed-prompt wording.

## Source

- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
- [ADR: A takeover posts a notice and waits two minutes](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b)
- [PDR: Leases are seen through agents and reports, not on the board](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)
