---
schema: 1
kind: card
title: "Merge: a conflicted card whose lane was removed outright still lands in a lane with no index.md"
order: 1024
labels: [{text: "merge", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-23T18:46:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T18:46:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The merge skill can still leave a card in a lane folder with no `index.md` on one path, and a restore into the trash keeps an old stamp. Both were found in the review of the delete fixes and left out of that card.

## Evidence

- **Conflicted card whose lane was removed outright.** `process_card` in `skills/merge/scripts/lanework-merge.py` places a card whose winning lane is gone at the lane's trashed copy, else at ours' or theirs' location (`L = trashed_lane(repo, board, L) or lo or lt`). When the lane was removed with `git rm -r` and has no trashed copy, that location can be the gone lane itself. Reasoned from the code by the builder and the reviewer, not reproduced. `rules.md` documents the behaviour in its "card's lane gone" row.
- **The restore path already does better.** `restore_deleted` puts such a card in `.trash/<card>`, so the two paths follow different rules.
- **No restamp on a restore into the trash.** The in-board guide says the trash sorts by `modified.at` and that a trash move restamps. A card restored to `.trash/` keeps its old stamp and sorts low. Reasoned, not run.
- **An untracked file in an orphan card folder** makes the board fail validation after a restore (duplicate identity). The pass says so and exits non-zero. It is not listed under Limits in `rules.md`.

## Done when

- A conflicted card whose lane is gone and has no trashed copy lands in `.trash/<card>`, as the restore path does, with a `merge-case.sh` row that fails first.
- A card the pass puts in the trash is restamped, or Limits says why not.
- Limits names the untracked-file case.
