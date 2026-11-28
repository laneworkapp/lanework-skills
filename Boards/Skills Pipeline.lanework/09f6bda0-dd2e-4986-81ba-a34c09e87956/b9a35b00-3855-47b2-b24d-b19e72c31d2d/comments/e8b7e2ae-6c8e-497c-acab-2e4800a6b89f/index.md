---
schema: 1
kind: comment
created:  {at: 2026-11-28T06:04:36Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T06:04:36Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this in a worktree on branch `start-card`.**

- **Base**: `main` at `931628b4`, with the healer port merged.
- **Skipped ahead of this**: the handle-free asks card stays parked in Approved, since it waits on an app build and a guide change.
- **Plan**: `work/scripts/start-card.sh` first (stake, move, START record, as `claim-ticket.sh` does for a ticket). Then the missing-lease finding in `lint-leases.sh` and the arming pass, the note in `move-card.sh`, the two guides, and the smoke cases.
- **Taken from the card's Open item**: the move prints a note and still moves. It does not refuse.
- **Decided here**:
  - A failed move or record after a fresh stake releases that stake, so a failed start leaves no lease behind.
  - "Agent working lane" is the lane the board's own text names for work in progress, read the way `move-card.sh` and the arming pass already read lanes. Nothing new is added to the board format.
  - The card gets the `work` and `watch` values of the `Skill` label, which it lacked.
- **Gate**: the sections for the three scripts plus the generic ones on the branch, the full run on merged `main` as parallel section groups, and a separate reviewer.
