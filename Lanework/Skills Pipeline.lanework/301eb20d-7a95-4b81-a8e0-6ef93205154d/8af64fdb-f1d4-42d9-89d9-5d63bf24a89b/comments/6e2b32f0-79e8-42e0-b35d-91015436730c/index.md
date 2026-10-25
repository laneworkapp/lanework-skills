---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:59:55Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T22:59:55Z, by: {name: fixer, kind: agent, model: opus}}
---
**START: fixer building `merge` on branch `merge-skill` (worktree `.claude/worktrees/merge-skill`), for the lead's build cycle.**

Plan: `skills/merge/` (`SKILL.md`, `references/rules.md`, `scripts/lanework-merge.py`, `scripts/merge-board.sh`), then plugin.json, README, a line in writes.md § Git, and this board's Skill list. A new smoke case (`tests/merge-case.sh`, called from smoke) runs as a merge and as a rebase.

- **Decided**: the driver can't safely write into the working tree when the card's path changes during the merge. Git checks out the result only after every driver call, and on a rename/rename it passes the base path as `%P` (measured on git 2.54). So the driver writes the merge comment in place only when the card's folder already exists in our tree. Otherwise it logs the loss to `.git/lanework-merge/`, and the pass posts it.
- **Decided**: a trashed-vs-edited card is resolved by the driver when the trash is the later side. When the edit might be later, the driver writes the merged file with no markers, then exits 1, so the pass can restore the card to its lane.
- **Decided**: `install` copies the script into `.git/lanework-merge/` and points the driver there. That way a plugin update or a moved skill folder can't break a clone's driver.
- **Decided**: when one side deleted a card for good and the other edited it, the edit is kept and the merge comment says so. The unmerged-path-means-ours rule still applies to paths outside a card. Otherwise a rebase (where ours is upstream) would drop the edit silently.
