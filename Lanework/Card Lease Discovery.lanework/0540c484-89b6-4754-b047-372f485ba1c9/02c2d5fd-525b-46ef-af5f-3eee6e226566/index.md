---
schema: 1
kind: card
title: "Q12: What a lease write restamps and commits"
order: 12288
labels: [{text: "Round 3", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:03:03Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:05:50Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
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

## Ruling

**2026-11-14**: A, as recommended. "A: Restamp `modified`. Never commit it alone, only with the holder's next commit."
ADR: [ADR: A lease write restamps modified and is never committed alone](lanework://33527992-d72c-417b-85a2-1b62bea96794/aec193e9-55d2-4f60-9cd6-17a05258e307)
