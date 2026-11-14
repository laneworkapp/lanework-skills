---
schema: 1
kind: card
title: "ADR: One lanework script holds the lease mechanism and its timer"
order: 8192
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:05:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:05:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Question: [Q11: Where the lease mechanism lives](lanework://33527992-d72c-417b-85a2-1b62bea96794/5da76e6f-2a5e-449d-89e3-821636bc9b8c)

The whole lease mechanism lives in one script in `lanework/scripts/`, with stake, renew, check and release, and every skill calls it. Stake starts the renewal timer as a background loop, and release stops it. No skill writes `claimed` itself, so the read-back, the timer and the "lease lost" record behave the same everywhere.

## Considered options

- Each skill writes `claimed` itself, following a rule in `lanework/references/writes.md`: five skills re-implement the read-back and the timer, and drift apart.
- A shared function in `lib.sh`, with each skill running its own timer: the write is shared, and the part most likely to go wrong is not.

## Consequences

- The timer is a background process that outlives the command that started it. A session that dies without releasing leaves it running until it finds its lease gone or its session dead, so the loop needs its own stop condition.
- A subagent never calls the script to stake: its session does (the session holds the lease).

## Related

- [ADR: A lease runs 30 minutes, renewed by a timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/ce03dec0-06e0-4fa8-ac29-671c59ba6930)
- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
