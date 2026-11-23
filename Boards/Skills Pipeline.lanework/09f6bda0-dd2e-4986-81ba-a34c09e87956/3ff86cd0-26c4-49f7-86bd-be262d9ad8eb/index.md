---
schema: 1
kind: card
title: "Merge: a delete against an added comment leaves a folder with no index.md; a delete against a bare move drops the card"
order: 3072
labels: [{text: "merge", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-23T00:30:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:50:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-23T17:20:01Z
---
Two merges still lose or strand a card the other side deleted for good. If the other side only added a comment or an attachment, git merges with no conflict and leaves those files in a folder with no `index.md`. If the other side only moved the card, the pass sees no edit and drops the card. Both reproduce on throwaway repos, both ways, and the board validator passes both broken results. One change in `lanework-merge.py` for each, verified on a prototype copy.

## Evidence

Run 2026-11-23 against `skills/merge/scripts/lanework-merge.py` on `main` (after `82ed7084`). Each case gets its own repo under `mktemp -d`. The setup follows `tests/merge-case.sh`: a board founded with `found-board.sh`, `.schema` and `CLAUDE.md` copied from this board, the driver installed, and one card X in Ideas holding `index.md`, two comments and an attachment (`index.md` and `blob.png`), committed as the base. Branch `side` and `main` then diverge, `git merge --no-edit side` runs on `main`, then `merge-board.sh <repo> --model test`.

| case | main | side | git | pass | X afterwards |
|---|---|---|---|---|---|
| comment | `git rm -r` X | adds a comment | `Merge made by the 'ort' strategy.`, exit 0 | `No merge, rebase or cherry-pick in progress. Not re-homed: <X> (git and the disk disagree on where the card is: commit the move first).` exit 0 | the new comment alone, no `index.md` |
| comment, mirror | adds a comment | `git rm -r` X | exit 0, five deletions | same | the new comment alone |
| attachment | `git rm -r` X | adds an attachment | exit 0 | same | the new attachment's two files alone |
| comment, rebase | `git rm -r` X | adds a comment; `git rebase main` on `side` | `Successfully rebased`, exit 0 | same | the new comment alone |
| comment, git stops elsewhere | `git rm -r` X; edits card Y's body | adds a comment to X; edits Y's body later | stops on Y | resolves Y, then the same `Not re-homed` line | the new comment alone, committed with the merge |
| bare move | `git rm -r` X | `git mv` X to Done, no restamp | `CONFLICT (rename/delete)` ×5, exit 1 | `5 unmerged board paths resolved. Nothing was lost, so no merge comment.` exit 0 | gone |
| bare move, mirror | `git mv` X to Done | `git rm -r` X | same | same | gone |
| bare move into the trash | `git rm -r` X | `git mv` X to `.trash/` | same | same | gone |
| control: restamped move | `git rm -r` X | `git mv` X to Done, `modified` and `order` rewritten (what the app and `move-card.sh` write) | rename/delete and modify/delete | `Merge comments on 1 card: "X" (The other side deleted this card for good; the edited card is kept.)` | whole, in Done |

The validator printed `failures    0` after every row. It accepts a card folder with no `index.md`, as the closed card `28c22261` found.

## Cause

- **Delete against an addition.** The added files and the deleted unchanged files never collide, so git calls no driver and leaves no unmerged path. `cmd_resolve` builds cards only from unmerged paths (`lanework-merge.py:1166`, `1180-1189`), so `process_card` never sees X. The only code that looks at the orphan folder is the re-home pass. `rehome_card` (`1119-1128`) finds no `index.md` for the card anywhere, so `homes` and `index_homes` are both empty and `len(homes) != 1` skips it. The message blames an uncommitted move that never happened.
- **Delete against a bare move.** Git stops on rename/delete, so `process_card` runs. With one side missing (`924-932`), it keeps the card only when `lb is None or present != fb` (`927`). `trees.card` keys each file map by the path within the card, so a pure move leaves `present == fb`, and `L = None` drops the card (`932`). A move that restamps changes `index.md`, which is why the control row keeps the card: a delete loses to a stamped move but wins against a bare one.

## Proposal

- **Bare move** (`process_card`, `927`): a changed location counts as a change. `if lb is None or present != fb or locs[side] != lb`. The existing whole-card path (`955-957`) then brings back the mover's whole tree at its new place. The merge comment says `The other side deleted this card for good; the moved card is kept.` when nothing but the location changed.
- **Addition against a delete** (`rehome_card`): when a card's tracked files sit in exactly one folder and no tree on disk or in git has its `index.md`, restore the survivor's whole card into that folder instead of skipping it. The survivor's tree is the first one of these that holds the card's `index.md`: the other side of an operation in progress (`op_state`, then `HEAD`); else a parent of a merge `HEAD`; else the parent of the last commit that deleted the card's `index.md` (`git log -1 --diff-filter=D HEAD -- ':(glob)<board>/**/<card>/index.md'`). Write the files that are missing, never overwrite one that is there, post the merge comment `The other side deleted this card for good; a comment or attachment was added on this side, so the whole card is kept.` signed with `--model`, stage it all, and commit nothing. The report gets its own sentence, `Restored whole against a delete: "<title>" (<n> files). Staged, not committed: commit it.`, not the re-home one.
- Two folders with no home, or no tree with an `index.md`: skip as now, with a message that names the real reason, not "commit the move first".
- `skills/merge/references/rules.md`, Placement: the "deleted for good" row brings the whole card back for an edit, an added comment, attachment or relation, or a move, which ends with "`merge-board.sh` restores it after git finishes, staged". The "Only a comment or attachment added against the delete: not handled" sentence goes. `SKILL.md` step 2 already says to run the pass after a pull git finished alone, so it needs no change.
- `CHANGELOG.md`: one user-facing entry at release.

A prototype of both changes, applied to a copy of the script outside the repo, gave these results. Every row above came back whole, in the right folder: Ideas for the additions, Done for the moves, `.trash/` for the bare move into the trash. Each had one merge comment and the board validated. Every existing `tests/merge-case.sh` mode passed on a copy of `skills/` and `tests/` holding the prototype: `merge`, `rebase`, `nodriver`, `clean`, `rebasemove`, `dirty`, `appside`, `delete`, `stamps` and `interrupt`. That includes `clean` case (j), where a card git and the disk disagree on is still skipped.

## Out of scope

- A card with an added file on one side and a move on the other (no delete). That is the re-home, and it already works.
- Making git itself stop. No attribute makes git call a driver on files that don't conflict, so the fix lives in the pass, which the skill already says to run after git finishes on its own.
- The validator accepting a folder with no `index.md`. That is the app's file in each board's `.schema`, so the new cases assert on the files directly.
- A git hook that runs the pass after every merge. That is a separate idea if wanted.

## Risks

- **History lookup after the fact.** In a rebase, the fallback restores from the parent of the deleting commit, which is the base card plus the orphan's files. If the adding side also removed a file that the delete then removed again, that file comes back. Git finishes on its own only when the survivor's other changes to existing files were deletions, so this is narrow. The proposal names it in `rules.md` Limits instead of walking the history further.
- **A deliberate delete comes back.** That is the rule (an edit or addition beats a delete), and it is reversible: delete again. Nothing comes back unless the other side's file is still in the tree.
- **Restore during an operation that later aborts.** The restore only writes untracked files and stages them inside the operation, as the re-home already does. `git merge --abort` removes them.
- **Report wording.** Re-home and restore must not share a sentence: the restore brings back files nobody on this side touched, and the user should see that before committing.

## Cases to add

In a new `tests/merge-case.sh` mode, `deleteadd` (`delete` needs git to stop, and these must not), plus rows in `delete`. Each fails on the current script.

- `deleteadd`: rm on ours, a comment added on theirs. Then the mirror, then an attachment added on theirs, then a relation added on theirs. Git finishes with exit 0. The pass exits 0, the report has the `Restored whole` sentence and no `Not re-homed` line, every base file is back byte for byte, the added file is there, and there is one merge comment. After the commit, `clean_status` holds.
- `deleteadd`: the same addition with a rebase in place of the merge.
- `deleteadd`: the addition, with git stopping on another card's body. The pass resolves both in one run.
- `delete` rows: rm on ours, a bare `git mv` to another lane on theirs, then the mirror. The card is whole in the moved lane, and the merge comment says `the moved card is kept`. A bare `git mv` into `.trash/` against rm: the card is whole in `.trash/`.
- The existing X6 control (rm against no change) still stays gone.
- `tests/smoke.sh`: one `ok` line for `deleteadd` beside lines 1916-1923.

## Done when

- [ ] A delete against an added comment, attachment or relation ends with the whole card back, never a folder without `index.md`. That holds after a merge git finished, a rebase, and a merge stopped on another path, both ways.
- [ ] A delete against a bare move ends with the whole card in the moved lane and a merge comment, both ways, a bare move into `.trash/` included.
- [ ] A folder the pass still can't restore is named in the report with its real reason.
- [ ] `deleteadd` and the new `delete` rows are in `tests/merge-case.sh` and called from `tests/smoke.sh`. Each fails on the current script, and `tests/smoke.sh` passes.
- [ ] `rules.md` Placement and Limits match the new behavior.
- [ ] The fix ships as a plugin release.

## Decisions in this proposal

An added comment or attachment brings back a card the other side deleted, whole. The owner approved this on card `28c22261` ("Decision in this proposal"). It went undelivered only because the pass never saw the case. It is not reopened here.

A delete against a bare move keeps the whole card where the mover put it, with a merge comment (owner ruled A, 2026-11-23). A bare move into `.trash/` is kept in `.trash/` like any other.

## Release

Patch: fixes only. Both bugs lose or strand board data in a shipped skill.
