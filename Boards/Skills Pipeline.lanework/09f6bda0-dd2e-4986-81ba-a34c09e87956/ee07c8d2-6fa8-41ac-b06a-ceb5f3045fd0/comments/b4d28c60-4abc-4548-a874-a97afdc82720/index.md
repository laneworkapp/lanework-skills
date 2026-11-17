---
schema: 1
kind: comment
in-reply-to: 9f74772a-9cb7-4d12-85ab-2f19231034a9
created:  {at: 2026-11-17T12:31:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Lead's ruling after round 2: fix it. The fixer makes the arm step follow both branches, and the reviewer re-checks that finding only.**

- **Finding**: Blocking 1 of round 2, the `comment` row arms only a card answered now, not one found already answered.
- **Why fix and not accept**: two cards in Approved today (d42328d4, 714177b9) print the false-alarm `comment` line. Each would be skipped when it reaches the top.
- **Scope**: inside this card. It moves the sweep into watch and has to keep what the sweep did.
- **Round cap**: this is the one fix after round 2 that `team.md` allows; no third open review.
