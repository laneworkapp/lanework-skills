---
schema: 1
kind: card
title: "A lease's holder is the stamp's by, with the harness session id required"
order: 1024
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T13:42:43Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: ADR1
---
Question: [Q1: What identifies a lease's holder](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb)

A lease's `by` is the same `by` map a stamp carries, with `session` required and holding the harness session id, read from the environment by the claim script. The id already exists, so a session knows its own lease after its context is compacted, and stamps and leases keep one shape.

## Considered options

- A token minted on a session's first claim and kept in a state file: one more file to lose, and a second identity beside the stamp's.
- Name, host and process id: a process id does not survive a restart, and two sessions on one host share name and host.

## Consequences

- A session with no session id in its environment cannot hold a lease.
