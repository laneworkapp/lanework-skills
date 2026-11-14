---
schema: 1
kind: card
title: "Every card-writing script checks the lease first"
order: 15360
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:45:50Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: ADR13
---
Question: [Q21: A holder whose timer died](lanework://33527992-d72c-417b-85a2-1b62bea96794/39811630-aa7b-410d-a181-f9ee942d0c77)

Every script that writes a card checks the card's lease first. A session about to post a comment or move a card it holds learns there what its background loop would have told it: a lease lapsed and still its own is renewed and the loop restarted; a lease carrying another session's `by` means stop and record the loss. This covers a holder whose background loop died while its session works on, which renewal, the lost-lease check and the takeover notice all depend on.

## Considered options

- Accept the gap and let the 50-card trial show it: the holder that lost its card never learns, and keeps writing to it.
- A second process that restarts a dead loop: a watcher for the watcher, which can die too.

## Consequences

- A holder learns of a lost lease at its next card write at the latest, whatever happened to its loop.
- Card-writing scripts depend on the lease script. A hand-rolled write that skips them skips the check.
- A write to a card the session does not hold, such as an answer on someone else's card, is not blocked: the check only acts on a lease the writer holds or held.

## Related

- [ADR: A takeover posts a notice and waits two minutes](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b): names this case as uncovered
- [ADR: A lost lease leaves the work in place, and the loser stops](lanework://33527992-d72c-417b-85a2-1b62bea96794/3b8d6e0b-1668-4e67-80ab-4a88fda8ad96)
