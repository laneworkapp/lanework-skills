---
schema: 1
kind: comment
created:  {at: 2026-11-28T13:17:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T13:17:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this in a worktree on branch `padded-name`, alongside the start-card build.**

- **Base**: `main` at 4746665d.
- **Why now**: the owner approved it to the top of Approved. It touches neither file set of the start-card branch apart from separate sections of `tests/smoke.sh`.
- **Plan**: the padded-name refusal in `heal-descriptors.py`, the header line in `found-board.sh`, one smoke case shown failing first.
- **Gate**: the heal and generic sections on the branch, a separate review, then the full run on merged `main` as parallel section groups.
- **Order of merge**: whichever of the two branches is approved first merges first; the other rebases.
