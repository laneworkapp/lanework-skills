---
schema: 1
kind: comment
created:  {at: 2026-11-22T22:42:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T22:42:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: the claim and all three suspicions reproduce on a throwaway repo. One fix in `lanework-merge.py`, three new merge cases.**

- **Main claim**: reproduced both ways. Delete on one side, body edit on the other: the card comes back with `index.md` and the merge comment only. The pass exits 0 and says the card is kept.
- **Stamps**: a stamp with no timezone on one side makes the pass die with a traceback, exit 1, path left unmerged. A date alone, a space separator and a lowercase `t` do the same.
- **Comment-only edit**: reproduced both ways. The folder is left with a comment and no `index.md`. Same cause as the main claim, same fix.
- **Remove before rewrite**: reproduced by simulated interruption. An uncommitted comment edit was gone from the worktree and the index.
- **Why smoke missed it**: the delete-against-edit row in `tests/merge-case.sh` is a card holding `index.md` alone.
- **Validator**: it passed every broken result. It is the app's file, outside this repo; the new cases assert on files directly.
- **Label**: `merge` added, the card was filed without a Skill label.
- **Decision in the body**: a comment-only edit brings a deleted card back whole, as `rules.md` already has it.
- **Open calls**: none.
- **Release**: patch, worth one of its own.
