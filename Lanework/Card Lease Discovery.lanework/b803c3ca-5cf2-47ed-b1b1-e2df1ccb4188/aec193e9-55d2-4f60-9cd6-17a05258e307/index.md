---
schema: 1
kind: card
title: "ADR: A lease write restamps modified and is never committed alone"
order: 9216
labels:
  - {text: "ADR", rank: 1, kind: {type: "record", text: "Record"}}
  - {text: "accepted", rank: 1, kind: {type: "status", text: "Status"}}
created:  {at: 2026-11-14T14:05:50Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:05:50Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Question: [Q12: What a lease write restamps and commits](lanework://33527992-d72c-417b-85a2-1b62bea96794/02c2d5fd-525b-46ef-af5f-3eee6e226566)

Every lease write (stake, renewal, release) restamps the card's `modified`, as the guide requires of any write, and is never committed on its own. It rides along with the holder's next board commit, and release clears `claimed` before the closing commit. Across machines a lease is only a hint, so a commit per renewal would buy nothing and fill the history with renewals.

## Considered options

- Commit and push each lease write: a commit every 15 minutes per held card, for a hint.
- Leave `modified` alone on a lease write: breaks the guide's rule that every write restamps, and hides the write from a merge.

## Consequences

- A card held but not yet committed shows as modified in `git status` while the work runs.
- A commit made mid-work carries a live lease to other machines, where it reads as a hint and lapses by its `until`.
- A renewal changes `modified`, so a board sorted or merged by `modified` sees a held card as freshly touched.

## Related

- [ADR: A lease holds on one machine; across machines it is a hint](lanework://33527992-d72c-417b-85a2-1b62bea96794/94e3d45e-37cf-4c39-a633-87610ab297b4)
