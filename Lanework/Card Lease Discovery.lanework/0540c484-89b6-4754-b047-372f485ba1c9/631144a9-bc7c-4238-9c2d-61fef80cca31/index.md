---
schema: 1
kind: card
title: "A handshake between agents"
order: 20480
labels: [{text: "Round 5", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:32:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Q18
---
The map kept a handshake between agents in reserve: a way for one agent to ask a holder "are you still working this?" before taking a card. Do the rulings so far leave a need for it?

## Options

- A: No handshake. A lapsed lease is taken over at once (Q15), a live holder that loses a card stops (Q9), and nothing in between needs the two to talk.
- B: A handshake before takeover: the taker posts a comment and waits a few minutes for the holder to renew or answer.

## Recommended

A. A holder that is alive renews, so a lapsed lease already is the answer to "are you still there", and B is the grace period Q15 declined.


## Options, revised 2026-11-14

After the owner proposed a check before takeover: "hey i'm about to take over this lease, is anyone alive holding it?"

- A: No check. A lapsed lease is taken over at once, as Q15 ruled.
- B: A notice before takeover. The taker posts its takeover record as a notice, waits two minutes and reads the lease again: renewed means back off, unchanged means stake. A holder's timer reads the card each minute and renews when it sees a notice. This supersedes Q15's "at once".
- C: A two-way handshake: the holder answers the notice with a comment of its own.

Recommended: B. A live holder whose lease only looks lapsed keeps its card, which is the case the clock guard of Q14 left uncovered, and a renewal is all the answer needed.

## Depends on

- [Q9: A lost lease and the work in flight](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2): the work stays, the loser stops
- [Q15: Taking over a card whose lease lapsed](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53): taken over at once, with a record

## Ruling

**2026-11-14**: B, as recommended after the owner proposed it. "B: Post a notice, wait two minutes. A live holder answers by renewing." Earlier: "actually this maybe a good check before taking over a lease to send a broadcast \"hey i'm about to take over this lease, is anyone alive holding it?\" or something like that. not a handshake per se but a check before taking over might not be a bad idea. wdyt?"
ADR: [ADR: A takeover posts a notice and waits two minutes](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b)
Supersedes [ADR: A lapsed lease is taken over at once, with a record](lanework://33527992-d72c-417b-85a2-1b62bea96794/9a6850de-9571-4e7c-bacd-d0758a2bfa08), from [Q15](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53).
