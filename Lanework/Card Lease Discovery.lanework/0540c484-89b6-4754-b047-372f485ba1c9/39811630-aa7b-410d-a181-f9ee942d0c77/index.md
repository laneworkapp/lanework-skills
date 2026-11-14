---
schema: 1
kind: card
title: "Q21: A holder whose timer died"
order: 21504
labels: [{text: "Round 6", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:37:46Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:45:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Renewal, the lost-lease check and the takeover notice all run in the holder's timer. If the timer dies while its session works on, the lease lapses, the notice goes unseen, another agent takes the card, and the first holder never learns. What covers a holder whose timer died?

## Options

- A: Every script that writes a card checks the lease first. A session about to post a comment or move a card it holds learns there that its lease is lapsed or lost: lapsed and still its own, it renews and restarts the timer; another session's, it stops and records the loss (Q9).
- B: Accept the gap. The 50-card trial (Q20) shows whether it happens: it leaves two START comments from different sessions on one card.
- C: A second watcher process that restarts a dead timer.

## Recommended

A. The card-writing scripts already exist and already read the card, so the check is one call, and a holder then learns of a loss at its next write at the latest.

## Depends on

- [Q18: A handshake between agents](lanework://33527992-d72c-417b-85a2-1b62bea96794/631144a9-bc7c-4238-9c2d-61fef80cca31): a notice before takeover, read by the holder's timer
- [Q11: Where the lease mechanism lives](lanework://33527992-d72c-417b-85a2-1b62bea96794/5da76e6f-2a5e-449d-89e3-821636bc9b8c): one lanework script, with the timer
- [Q9: A lost lease and the work in flight](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2): the work stays, the loser stops
- [Q20: How the lease is judged to work](lanework://33527992-d72c-417b-85a2-1b62bea96794/536cb934-d63d-40c9-85dc-5819b6dd13d6): smoke plus a 50-card trial

## Ruling

**2026-11-14**: A, as recommended. "A: Every script that writes a card checks the lease first."
ADR: [ADR: Every card-writing script checks the lease first](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)
