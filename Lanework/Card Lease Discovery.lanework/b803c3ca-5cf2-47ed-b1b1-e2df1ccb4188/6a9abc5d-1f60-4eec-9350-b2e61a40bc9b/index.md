---
schema: 1
kind: card
title: "ADR: A takeover posts a notice and waits two minutes"
order: 14336
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:37:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:37:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Question: [Q18: A handshake between agents](lanework://33527992-d72c-417b-85a2-1b62bea96794/631144a9-bc7c-4238-9c2d-61fef80cca31)

Before taking a card whose lease has lapsed, an agent posts its takeover record as a notice: it is taking this card from that session unless the lease is renewed. It waits two minutes and reads the lease again. Renewed means back off, unchanged means stake as on a free card. A holder's timer reads the card once a minute for a notice and renews at once when it sees one, so a live holder answers by renewing and no reply comment is needed. This keeps a card with a holder whose lease only looks lapsed, because the clock ran behind or a renewal was lost.

## Considered options

- No check, takeover at once: the earlier ruling. A live holder with a lapsed-looking lease loses its card and learns of it up to 15 minutes later.
- A two-way handshake in comments: a renewal already says "alive", so a reply adds a comment and nothing else.

## Consequences

- Every takeover costs two minutes. Takeovers follow a crash, so they are rare.
- The timer has two jobs: renew every 15 minutes of elapsed time, and read the card each minute for a notice.
- A holder whose session is alive and whose timer died does not see the notice. The takeover goes ahead and that holder never learns.
- A notice whose taker backed off stays in the thread as a record that a takeover was tried.

## Related

- [ADR: A lapsed lease is taken over at once, with a record](lanework://33527992-d72c-417b-85a2-1b62bea96794/9a6850de-9571-4e7c-bacd-d0758a2bfa08): superseded by this record
- [ADR: The clock guard is a range check against now, with an elapsed-time timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/674f3c98-33a5-41f5-acb3-7f59abafdfcf): the notice covers the clock running behind, which the guard does not
