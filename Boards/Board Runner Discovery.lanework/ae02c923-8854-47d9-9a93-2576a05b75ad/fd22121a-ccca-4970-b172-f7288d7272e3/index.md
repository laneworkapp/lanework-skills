---
schema: 1
kind: card
title: "Q14: Lease length and expiry"
order: 6144
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:20Z, comment: 69e41799-1afa-4f8f-927e-cfea458fa6cd}
created:  {at: 2026-10-30T15:30:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
How long does a lease last, and what happens when it runs out?

## Options

- A: Fixed per job kind, such as 30 minutes for board jobs and 3 hours for builds. The runner renews it while the job runs, and an expired lease means the card is free.
- B: One fixed length for every job, never renewed.
- C: No expiry. The runner clears it when the job exits, and a crash leaves it for the owner to clear.

## Recommended

A. Renewal keeps a long build covered, and expiry frees a card whose job died with the machine.

## Depends on

- [Q6: How a card shows it is taken](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1): a lease key in card frontmatter
- [Fact: the board format has no claim or presence, and keeps unknown keys](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/da63a42c-f5f7-4d48-9cd6-d586800e0d78)
