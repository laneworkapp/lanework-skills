---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:45:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:45:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: both defects reproduced and traced; one call is open, the outcome of a delete against a bare move.**

- **Delete against an added comment or attachment**: git merges with no conflict, so the pass never sees the card and leaves a folder with no `index.md`. Not an open call: the whole card coming back was approved on card `28c22261` and went undelivered. The fix restores it after git finishes, staged and not committed.
- **Delete against a bare move**: the pass compares files by their path inside the card, so a move with no restamp counts as no change and the card is dropped. The app and `move-card.sh` always restamp, so this only fires on a move by hand, Finder or `git mv`.
- **Run**: nine cases on throwaway repos, both ways. A prototype of both fixes on a copy outside the repo brought every card back whole, and all ten existing merge-case modes still passed on it.
- **The open call**, for the bare move:
  - **A (recommended)**: keep the whole card where it was moved, with a merge comment. A stamped move already gets this. Cost: a card someone deletes again.
  - **B**: the delete wins. The report names the dropped card. No merge comment is possible, since no card is left to hold one.
  - **C**: as A, except a bare move into the trash lets the delete win, since both sides meant to remove it. A stamped move into the trash still comes back today, so the two would differ.
