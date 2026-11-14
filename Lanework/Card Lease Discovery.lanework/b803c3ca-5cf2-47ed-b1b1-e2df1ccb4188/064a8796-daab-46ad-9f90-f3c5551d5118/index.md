---
schema: 1
kind: card
title: "ADR: The session holds the lease; its subagents never stake"
order: 6144
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:01:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:01:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
Question: [Q7: A subagent shares its session's id](lanework://33527992-d72c-417b-85a2-1b62bea96794/144897f2-11a2-4147-b862-579adf7dc6c9)

A lease is held by a session, never by one of its subagents. A subagent shares its parent session's id, so the session stakes the lease before it hands a card to a subagent, keeps it renewed while the subagent works, and releases it after. Subagents work under their session's leases and never stake one. `dispatch` and a build lead already hand each card to one subagent, so the session knows who works what, and the lease keeps the one shape Q1 settled.

## Considered options

- A subagent adds an `agent` name to `by`, so the holder is the session id plus that name: a second identity scheme, and a name the subagent must be given and keep.
- A session and its subagents count as one holder, each staking as the session: two subagents of one session could both stake one card and each read the lease as its own.

## Consequences

- A subagent prompt that works a card names the lease its session holds, and tells the subagent not to stake.
- Renewal runs in the session's timer, not in the subagent.

## Related

- [ADR: A lease's holder is the stamp's by, with the harness session id required](lanework://33527992-d72c-417b-85a2-1b62bea96794/31f5a0e4-1c31-43be-a36f-5fedd78a3bc9): the ruling this reconciles with the subagent fact
