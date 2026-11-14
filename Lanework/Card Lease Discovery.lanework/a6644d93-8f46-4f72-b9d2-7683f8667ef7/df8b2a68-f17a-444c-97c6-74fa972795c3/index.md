---
schema: 1
kind: card
title: "Q14: The clock guard: what it checks and on what basis"
order: 7168
labels: [{text: "Round 4", kind: {type: round, text: Round}}]
created:  {at: 2026-11-14T14:07:49Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:13:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
waiting: {for: anyone, since: 2026-11-14T14:13:53Z, comment: d9470fbb-324e-449e-95fa-591531db6a7e}
---
Q13 ruled that a lease gets a guard against a wrong clock. What does the guard check, on what basis, and what happens when it trips?

What can go wrong with `until`: the clock was ahead when the lease was written and has since been corrected, so a dead holder's card stays taken for hours. The clock was behind, so a live lease looks lapsed. A lease arrives by git from a machine with another clock. Or `until` was written by hand and not from the clock.

## Options

- A: A range check against now. No honest lease can end more than one lease length ahead, so an `until` over 35 minutes ahead of now is not a valid lease. The card is treated as free, and whoever stakes it records that it ignored one. An `until` in the past gets no guard: an early takeover is caught by the holder's next renewal.
- B: A consistency check against the card's own stamp. A lease is valid only if `until` is at most 30 minutes after the card's `modified.at`, since every lease write restamps it. This catches a mis-written `until`, and misses a clock that changed afterwards.
- C: Both A and B.
- D: A check against the card file's modification time on disk. It changes on any rewrite and on a git checkout, so it trips falsely.

## Recommended

A. It needs no new data, covers the case that hurts most (a card held for hours by nobody), and the one script that writes leases makes a mis-written `until` unlikely.


## Options, revised 2026-11-14

After the owner asked for a walk-through: A gains the holder's side.

- A: The range check, plus a timer that counts elapsed time. A reader treats `until` over 35 minutes ahead of now as no lease. The holder's timer renews every 15 minutes by waiting, never by reading `until`, and each renewal rewrites `until` from the clock.
- B: `until` must be within 30 minutes of the card's `modified.at`.
- C: A and B together.
- D: A check against the card file's modification time on disk.

Recommended: A. It compares the lease with a value the wrong clock did not also write, and a lease written under a wrong clock repairs itself within 15 minutes.

## Depends on

- [Q13: A wrong clock in until](lanework://33527992-d72c-417b-85a2-1b62bea96794/df0483a6-4636-464f-b31c-83fa219e9eea): a guard is wanted
- [Q4: Lease length and renewal](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665): 30 minutes, renewed by a timer
- [Q12: What a lease write restamps and commits](lanework://33527992-d72c-417b-85a2-1b62bea96794/02c2d5fd-525b-46ef-af5f-3eee6e226566): every lease write restamps modified
