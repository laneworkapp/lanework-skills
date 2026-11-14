---
schema: 1
kind: card
title: "Q11: Where the lease mechanism lives"
order: 11264
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:03:01Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:05:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Where does the lease mechanism live: staking, the renewal timer, the read-back, release?

## Options

- A: One script in `lanework/scripts/` with stake, renew, check and release, which every skill calls. Stake starts the renewal timer as a background loop, and release stops it.
- B: Each skill writes `claimed` itself, following a rule in `lanework/references/writes.md`.
- C: A shared function in `lib.sh`, with each skill running its own timer.

## Recommended

A. One script keeps the read-back and the timer the same everywhere, and every skill already sources `lanework` scripts.

## Depends on

- [Q3: Staking a lease on a free card](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb): write, wait, read back, provisionally
- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
- [Q7: A subagent shares its session's id](lanework://33527992-d72c-417b-85a2-1b62bea96794/144897f2-11a2-4147-b862-579adf7dc6c9): the session holds, subagents never stake

## Ruling

**2026-11-14**: A, as recommended. "A: One lanework script that every skill calls. It runs the renewal timer too."
ADR: [ADR: One lanework script holds the lease mechanism and its timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/0e5b4553-6ac0-47b9-862b-91951dc35948)
