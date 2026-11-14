---
schema: 1
kind: card
title: "Q12: What a lease write restamps and commits"
order: 5120
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
waiting: {for: anyone, since: 2026-11-14T14:03:03Z, comment: ddbb4c2e-2c8d-474d-872e-1fa0432c1dd8}
created:  {at: 2026-11-14T14:03:03Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:03:03Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
The guide says to update `modified` on every write, and a lease renews every 15 minutes. What does a lease write restamp, and is it committed?

## Options

- A: Each lease write restamps `modified`, as the guide requires, and is never committed on its own. It rides along with the holder's next board commit, and release clears `claimed` before the closing commit.
- B: Each lease write restamps `modified` and is committed and pushed at once.
- C: Lease writes leave `modified` alone.

## Recommended

A. Across machines a lease is only a hint (Q2), so a commit per renewal buys nothing, and leaving `modified` alone breaks the guide.

## Depends on

- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
- [Q2: One machine or several](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894): one machine, a hint across machines
