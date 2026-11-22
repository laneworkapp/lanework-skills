---
schema: 1
kind: card
title: "Fix the merge script dropping a kept card's unedited files"
order: 5120
created:  {at: 2026-11-22T22:20:35Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-22T22:35:16Z}
---
The board merge script keeps an edited card that the other side deleted, but drops every file in it that was not edited: its comments, attachments and relations.

## Evidence

- From a read of the script during a project audit, 2026-11-22. Read, not run.

- `skills/merge/scripts/lanework-merge.py`, lines 944 to 953. For each file, `if vo == vt or vt == vb: pick = ('o', vo)` and `elif vo == vb: pick = ('t', vt)`. When one side deleted the card, that side's value is `None`; for any file the other side left unchanged, the pick is `None` and the file is not written.
- Only files changed on the surviving side reach the "deleted on one side, changed on the other: keep the change" branch below.
- Sequence: one branch runs `git rm -r` on a card; the other edits its `index.md`; `merge-board.sh` runs. The card comes back holding `index.md` alone, and the merge comment at line 916 says "the edited card is kept."
- The lines were read here and the logic followed by hand. Not run. The subagent notes a three-commit test repo reproduces it without the app.
- Three suspicions in the same script, not traced: `later()` compares stamps with and without a timezone, which raises and aborts the pass; a delete against a comment-only edit leaves a comment in a folder with no `index.md`; the pass removes tracked paths (line 1001) before rewriting them (line 1015), so an interruption between loses uncommitted edits.

## Done when

- A card kept against a delete keeps the whole surviving side's tree: comments, attachments and relations.
- The three-commit reproduction is in the test suite and passes.
- The three suspicions above are each traced and either fixed or ruled out, with a line saying which.
- The fix ships as a plugin release.
