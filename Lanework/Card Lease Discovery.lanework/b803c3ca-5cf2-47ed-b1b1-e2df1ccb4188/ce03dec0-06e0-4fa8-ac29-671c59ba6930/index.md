---
schema: 1
kind: card
title: "A lease runs 30 minutes, renewed by a timer"
order: 4096
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T13:52:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: ADR4
---
Question: [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665)

A lease lasts 30 minutes from the moment it is staked or renewed. A timer started with the lease renews it whenever under 15 minutes remain, for as long as the work runs, and an expired lease means the card is free. The length is never sized to the expected work: renewal covers a long job, and a longer first lease only keeps a dead holder's card taken longer.

## Considered options

- A first lease sized to the agent's estimate, never under 30 minutes: no gain while the holder lives, and a longer wait after it dies.
- A fixed length per kind of work, never renewed: a build that overruns loses its lease mid-work.
- No expiry: a dead holder's card waits for the owner.

## Consequences

- Renewal runs on a timer, not at the agent's next write, so a long blocking command such as a build keeps its lease.
- 30 minutes matches the silence after which `dispatch` already reports a START as stale.

## Related

- [Q14 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3): the same question, open there and taken up here
