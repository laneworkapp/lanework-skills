---
schema: 1
kind: card
title: "Q18: A handshake between agents"
order: 1024
labels: [{text: "Round 5", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T14:32:31Z, comment: 4df47b79-1287-4606-93a0-1f3311ca44e5}
created:  {at: 2026-11-14T14:32:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:32:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The map kept a handshake between agents in reserve: a way for one agent to ask a holder "are you still working this?" before taking a card. Do the rulings so far leave a need for it?

## Options

- A: No handshake. A lapsed lease is taken over at once (Q15), a live holder that loses a card stops (Q9), and nothing in between needs the two to talk.
- B: A handshake before takeover: the taker posts a comment and waits a few minutes for the holder to renew or answer.

## Recommended

A. A holder that is alive renews, so a lapsed lease already is the answer to "are you still there", and B is the grace period Q15 declined.

## Depends on

- [Q9: A lost lease and the work in flight](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2): the work stays, the loser stops
- [Q15: Taking over a card whose lease lapsed](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53): taken over at once, with a record
