---
schema: 1
kind: card
title: "What identifies a lease's holder"
order: 1024
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T04:27:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q1
---
What goes in a lease's `by`, so that no two working agents can be confused and an agent can always tell whether a lease is its own?

## Options

- A: The stamp's `by` map, with a required `session` subkey that holds the harness session id. The claim script reads the id from the environment.
- B: A token the claim script mints on a session's first claim and keeps in a state file.
- C: Name, host and process id.

## Recommended

A. The id already exists and is read from the environment, so a session still knows its own lease after its context is compacted, and stamps and leases keep one shape.

## Depends on

- [Fact: a Claude Code session carries a unique id in its environment](lanework://33527992-d72c-417b-85a2-1b62bea96794/5c7c4fbb-f4fe-4368-839a-939a83b45b80)
- [Q6 on Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1): the lease is `claimed: {by, until}` in card frontmatter

## Ruling

**2026-11-14**: A, as recommended. "A: The stamp's `by` map, with the harness session id as a required `session`."
ADR: [ADR: A lease's holder is the stamp's by, with the harness session id required](lanework://33527992-d72c-417b-85a2-1b62bea96794/31f5a0e4-1c31-43be-a36f-5fedd78a3bc9)
