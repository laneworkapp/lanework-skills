---
schema: 1
kind: card
title: "plan: claim-ticket stakes a lease and still moves the ticket to Working"
order: 6144
labels: [{text: plan, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Make the `plan` skill stake a card lease when it claims a ticket, and keep its move to Working, so the lane shows the stage and the lease shows the holder.

## Files

- `skills/plan/scripts/claim-ticket.sh`: stake through the lease script before the move; back off if the stake is lost.
- `skills/plan/scripts/resolve-ticket.sh`: release in the closing write.
- `skills/plan/references/`: the page that describes claiming, updated to name the lease.
- `tests/smoke.sh`: cases for both scripts.

## Verified

- `tests/smoke.sh` passes, with new cases: `claim-ticket.sh` leaves the ticket in Working with a lease naming the caller; a second claim on a ticket with a valid lease is refused; `resolve-ticket.sh` leaves no `claimed` key.

## Done when

Both scripts go through the lease script, a ticket in Working whose session died is freed by its lease lapsing, and smoke is green.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)

## Source

- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
- [Q10: plan's Working lane beside the lease](lanework://33527992-d72c-417b-85a2-1b62bea96794/65be9ca2-633e-4ec9-8591-ff7ff12adea7)
