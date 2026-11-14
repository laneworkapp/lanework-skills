---
schema: 1
kind: card
title: "Lease trial: a collision lint and a clean run over the first 50 leased cards"
order: 7168
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Judge the card lease on live boards: add a lint that finds collisions in a board's threads, then run the first 50 cards worked under a lease and record whether the run was clean.

## Files

- `skills/work/scripts/lint-leases.sh`: new. Scans a board for "lease lost" records, for two START comments from different sessions on one card inside one lease, and for a card still carrying a lease lapsed long ago.
- `tests/smoke.sh`: cases for the lint on a throwaway board holding one of each.
- No skill prose. The trial's tally lives on this card's thread.

## Verified

- `tests/smoke.sh` passes with the lint cases: each of the three findings is reported, and a clean board reports none.
- The trial: the lint run on this repo's boards after the first 50 leased cards, output quoted in the closing comment.

## Done when

The lint exists and passes smoke, and the closing comment states the count of leased cards and of each finding. A clean run closes the card. One "lease lost" record or two-START card reopens the staking ruling, with a lock as the fallback, as a new card.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)
- [work: card-writing scripts check the lease, and START shrinks to a short plan](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa)
- [watch and dispatch: the session stakes a lease before working or handing off a card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233)
- [plan: claim-ticket stakes a lease and still moves the ticket to Working](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)

## Source

- [PDR: The lease works when smoke passes and 50 leased cards run clean](lanework://33527992-d72c-417b-85a2-1b62bea96794/67912ed8-4595-4514-8a6f-a5a629b473c8)
- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
