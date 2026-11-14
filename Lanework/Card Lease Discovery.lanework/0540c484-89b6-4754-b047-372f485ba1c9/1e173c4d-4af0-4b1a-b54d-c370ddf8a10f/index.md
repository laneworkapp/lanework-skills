---
schema: 1
kind: card
title: "Q17: Seeing held cards and freeing one by hand"
order: 17408
labels: [{text: "Round 4", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:07:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:32:00Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The app does not draw a key it does not know, so a lease is invisible on the board. How do you see which cards are held, and free one by hand?

## Options

- A: Through the script. A `list` command prints the held cards of a board with holder and time left, and any agent you ask runs it. You free a card by deleting the `claimed` line, or by telling an agent, which releases it by force and records that you said so.
- B: A visible mark as well: the script adds a `Held` label when it stakes and removes it on release, so the board shows held cards. A crashed holder leaves the label until takeover.
- C: Ask the app to draw `claimed`. An app request, outside this repo, and nothing until it ships.

## Recommended

A. It adds nothing to the board that can go stale, and the lease stays one key. C can follow as a request to the app without changing A.


## Options, revised 2026-11-14

After the owner asked how the script gets called: A gains the reports.

- A: Through agents and reports. Any agent you ask runs the script's `list`. Sweep and watch reports list held cards and flag a lapsed lease. You free a card by deleting the `claimed` line, or by telling an agent, which releases it by force and records that you said so.
- B: A, plus a `Held` label the script adds when it stakes and removes on release, so the board shows held cards.
- C: Ask the app to draw `claimed`. An app request, outside this repo, and nothing until it ships.

Recommended: A. Nothing on the board can go stale, and C can follow as an app request without changing A.

## Depends on

- [Q8: Releasing a lease](lanework://33527992-d72c-417b-85a2-1b62bea96794/0f36b65c-b027-461a-b9af-5c8db6e5fc5a): released in the closing write
- [Q11: Where the lease mechanism lives](lanework://33527992-d72c-417b-85a2-1b62bea96794/5da76e6f-2a5e-449d-89e3-821636bc9b8c): one lanework script
- [Fact: the board format keeps unknown keys and has no claim key](lanework://33527992-d72c-417b-85a2-1b62bea96794/674796c1-5068-49f7-ae1b-9a0c240e7e0a)

## Ruling

**2026-11-14**: A, as recommended. "A: Ask an agent, or read sweep and watch reports. Free one by deleting the line or telling an agent."
PDR: [PDR: Leases are seen through agents and reports, not on the board](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)
