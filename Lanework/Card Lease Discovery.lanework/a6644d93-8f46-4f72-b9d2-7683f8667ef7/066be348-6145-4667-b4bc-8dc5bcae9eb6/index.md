---
schema: 1
kind: card
title: "Q19: The untested app rewrite"
order: 2048
labels: [{text: "Round 5", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T14:32:33Z, comment: 6baae95d-ee67-41b9-8375-094e1825ee10}
created:  {at: 2026-11-14T14:32:33Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:32:33Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Nobody has tested whether the app, with a card open in its window, can write back an older copy of the file and so undo a lease write an agent made. How is that risk handled?

What it would do: put back an older `until`, or an older `by`. An older `until` makes the lease look shorter or lapsed, so another agent may take the card, and the holder finds out at its next renewal. The holder's own renewal, within 15 minutes, rewrites the lease in any case.

## Options

- A: Accept it for the design, and test it when the script is built: the build's checks include a card open in the app while a lease is staked and renewed. A failure there becomes a request to the app.
- B: Test it now, before anything else is decided, and settle this on the result.
- C: Accept it untested. The renewal read-back covers the worst case.

## Recommended

A. The worst case is already caught by renewal, so the design does not hang on the answer, and the build is where a real lease write exists to test with.

## Depends on

- [Fact: the board format keeps unknown keys and has no claim key](lanework://33527992-d72c-417b-85a2-1b62bea96794/674796c1-5068-49f7-ae1b-9a0c240e7e0a)
- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
- [Q9: A lost lease and the work in flight](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2): the work stays, the loser stops
