---
schema: 1
kind: card
title: "The lease works when smoke passes and 50 leased cards run clean"
order: 13312
labels:
  - {text: "PDR", rank: 2, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:36:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: PDR2
---
Question: [Q20: How the lease is judged to work](lanework://33527992-d72c-417b-85a2-1b62bea96794/536cb934-d63d-40c9-85dc-5819b6dd13d6)

The lease is judged to work on two measures. Smoke cases on throwaway boards cover every ruling: two racing stakes leave one holder, renewal, a lost lease, the clock guard, takeover, release and a forced release. And a trial on the live boards must come out clean over the first 50 cards worked under a lease: no "lease lost" record, no card with two START comments from different sessions inside one lease, and no card left held by a dead session past its `until`. Smoke shows the script does what was ruled, and only live use shows whether the provisional staking collides in practice.

## Considered options

- Smoke cases only: says nothing about collisions between real sessions.
- The live trial only: a clean trial with a broken edge case nobody happened to hit.

## Consequences

- One "lease lost" record or two-START card during the trial reopens the staking ruling, with the lock as the fallback.
- The trial needs the "lease lost" record's wording fixed, and a script that scans threads for two STARTs.

## Related

- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74): the ruling this trial tests
