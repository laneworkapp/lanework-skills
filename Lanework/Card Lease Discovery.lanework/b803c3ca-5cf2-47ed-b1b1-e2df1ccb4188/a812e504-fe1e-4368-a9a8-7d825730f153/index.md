---
schema: 1
kind: card
title: "ADR: Every skill takes a lease; START shrinks to a short plan"
order: 5120
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T13:55:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:55:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
Question: [Q5: Which skills take a lease, and the START comment](lanework://33527992-d72c-417b-85a2-1b62bea96794/69b77f01-fcab-4737-8892-31c7ecaadd3c)

Every skill that starts work on a card takes a lease first: `work`, `watch`, `dispatch`, `plan` and runner jobs. The START comment stays, but stops being a claim. It shrinks to a short plan: `START: <the plan in one line>`, then at most Scope, Verify and Where, about 40 words. The lease says who and until when, START says what, and START's session stamp lets a collision be found afterwards.

## Considered options

- Drop START, and let the first decision record carry the plan: a reader opening a card mid-work loses the plan, and the post-mortem check loses its stamp.
- Leases only for runner jobs and `dispatch`: contradicts Board Runner Discovery's ruling that interactive sessions honor the lease.

## Consequences

- Decisions that START comments carry today move to their own records, as `work/references/writing.md` already asks.
- `work/references/companions.md` stops reading a START as a claim.

## Related

- [Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1): interactive sessions honor the lease
