---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:40:47Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:40:47Z, by: {name: fixer, kind: agent, model: opus}}
---
**Round-1 rework decisions. All four blocking findings are fixed, and so are the lead's notes. Built on the owner's two rulings, stop on loss and both lane bodies inline.**

- **Decided**: the driver never writes anything except the file git hands it. On a loss it writes the merged file with no markers, then exits 1. The pass then posts the merge comment at the card's final path. This is stricter than "write in place in a plain merge". A comment written in place stays untracked, so it's left out of a merge commit that git finishes, which fails the "staged or committed" bar. The ledger and `lost-*.md` are gone, so an abort or a reset leaves nothing stale behind. This fixes B2, B3 and B4.
- **Decided**: lane and board bodies go through `git merge-file`. When edits overlap, the later body comes first, then the earlier under `## Merged from the earlier edit (<stamp>)`. Nothing is lost, so the merge doesn't stop.
- **Decided (B1)**: uncommitted edits are carried as ours and reported, not refused. A tracked path whose work-tree bytes match none of base, ours, theirs, the merge, or git's own marker output gets merged 3-way against theirs, then staged and named in the report.
  - **Rejected**: refusing the card. Measured on a rename/rename: git itself pulls the dirty file into the conflict, and `git merge --abort` then reverts it, so the local edit was lost with no way out.
- **Found while testing, fixed**: a comment posted on a card the other side moved stays at the old path. This happens with no rebase and no conflict: git 2.54 doesn't rename the directory. It's the real cause of B4. The pass now re-homes tracked files in a card folder that has no `index.md` into the card's one real folder, and stages them. It runs even with no operation in progress. `SKILL.md` now says to run the pass after any pull, and `rules.md` has a row for it.
- **Notes done**:
  - the driver runs `python3` from PATH against `$(git rev-parse --git-common-dir)/lanework-merge/`
  - the attachment title line names the attachment
  - an unclassified board file keeps theirs as `<name>.theirs.<ext>`
  - the pass normalizes CRLF before reading stamps
  - criss-cross duplicates are listed under Limits
