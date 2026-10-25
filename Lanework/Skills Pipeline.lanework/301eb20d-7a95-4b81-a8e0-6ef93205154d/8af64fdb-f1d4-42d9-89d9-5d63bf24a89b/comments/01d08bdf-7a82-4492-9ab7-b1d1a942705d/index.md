---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:09:50Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:09:50Z, by: {name: fixer, kind: agent, model: opus}}
---
**Decisions made while building, beyond the START record.**

- **Decided**: priority is state, read the guide's way. A card's priority is a `labels` entry of kind `priority`, and that kind is single-valued. A union would leave two priorities on one card. So a single-valued kind follows the state rule: the later side's entries of that kind win, whole. That covers `priority`, `component`, and any kind the board's `config.labels` marks `single`. Every other kind unions.
- **Decided**: the label union is 3-way per entry, so a label removed on one side stays removed. A plain union would bring back every deleted label.
- **Decided**: git can pair a deleted card with a new one by similarity. Seen in the smoke case, it would have merged one card's edit into another card. The driver refuses any pairing whose `created` stamps differ, because `created` never changes. The pass then finds the base side's own card by blob and rebuilds both cards by uuid.
- **Decided**: a lane or board body that loses a both-sided edit has no thread. The earlier text goes to `.git/lanework-merge/lost-<stamp>.md`, and the report names that file.
- **Decided**: in a rebase, the base is the replayed commit's parent (`REBASE_HEAD^`), not `git merge-base`. That's the base git itself uses for each pick.
- **Decided**: an inner recursive merge (a criss-cross base) uses a quiet copy of the driver. It writes no comments and no ledger entries for a tree that is never checked out.
- **Accepted limitation**: a merge that git finishes on its own never reaches the pass. A trash against a later edit always stops the merge, so that row is still covered.
- **Rejected**: changing `merge.renames` or the rename threshold. Both are repo-wide and would change the user's code merges too.
