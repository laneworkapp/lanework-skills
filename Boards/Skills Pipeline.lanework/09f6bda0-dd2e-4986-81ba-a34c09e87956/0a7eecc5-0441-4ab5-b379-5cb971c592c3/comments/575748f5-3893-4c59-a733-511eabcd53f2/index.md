---
schema: 1
kind: comment
in-reply-to: c20d87bd-ca46-47fc-ac2c-08f476f72022
created:  {at: 2026-11-28T20:06:50Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-28T20:06:50Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: APPROVE.** Every Done-when item holds as a merge, a rebase and a cherry-pick, the new prune only removes empty folders, and four mutations of mine all turn `lanegone` red; 5 notes, none blocking.

- **Stance**: adversarial (the lead's call: the code moves and restamps cards and deletes a folder)
- **Round**: 1
- **Card**: [0a7eecc5](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0a7eecc5-0441-4ab5-b379-5cb971c592c3), a conflicted card whose lane was removed outright
- **Branch**: `lane-gone` at `f945f245`

**Blocking**: none.

**Notes**

1. `skills/merge/scripts/lanework-merge.py:1100 @ f945f245` "write_atomic(repo, p, data)": the new `.trash/<card>` fallback from `gone_home` is a folder no tree holds, and `process_card` writes into it without checking what is already there. Measured: an untracked `.trash/<X>/index.md` holding `PERSONS-OWN`, made after `git merge` stopped and before the pass, was overwritten by the merged card (an untracked `note.txt` beside it survived). `restore_deleted` skips any path that exists ("Never overwrites a file"); `process_card` doesn't. I don't block on it (reasoned): only a hand-made file can sit there, because the app skips the card while its lane has no `index.md`, so nobody can trash it from the app, and the pass's own leftover from an interrupted run is rewritten with the same content. Fix if wanted: don't write a file into a `.trash/<card>` that no tree holds when the file already exists, or treat that folder as taken.
2. A card added (committed) on one side to a lane the other side removed outright is not a conflict, so git finishes the card alone and the pass never sees it. Measured: card N stays in the lane folder that has no `index.md`, the validator shows `index-less identity folders 1`, and the report says "validates", exit 0. The app hides N, which is the card's own symptom by another route. The bug was there before this branch (the same at the merge-base) and is outside this card's scope ("a conflicted card"). Worth a follow-up card.
3. An untracked file directly in the removed lane's folder (not inside a card) keeps that folder correctly: nothing is deleted. Measured: `draft.txt` survives, but the board then shows `index-less identity folders 1` and the report still says "validates", exit 0, without naming the folder. It could go in the same follow-up as note 2.
4. The loss line (`lanework-merge.py:959` "Its lane was deleted on the other side, so the card is in the trash.") doesn't name the lane. The card's Scope test row says "one merge comment naming the lane", but its Decided section gives this exact text and its Done-when asks only for the reason and no uuid prefix. So this doesn't break the spec in any way that matters. Still, the owner can't tell from the comment which lane was deleted, and the title could be read from the base tree. Optional.
5. On a card that one side's lane removal deleted, the merge comment carries two lines: "The other side deleted this card for good; the edited card is kept." and then the lane-gone line. Measured on G1, G2 and my cases. "Kept" next to "in the trash" reads oddly; a wording pass could fold the two together. Optional.

**Checked**

- **Correctness vs done-when** (all OWN RUN on throwaway repos, from the first 136 lines of `tests/merge-case.sh` plus my own modes):
  - No other live location → whole in `.trash/<card>`, with ours removing the lane and with theirs removing it, as a merge, a rebase and a cherry-pick: measured (s1 merge and rebase, s6 cherry-pick, plus the branch's `lanegone`).
  - Other live location → lands there (G3 in `lanegone`); both other locations in removed lanes → `.trash/<card>`, restamped, as a merge and a rebase: measured (s7).
  - One shared rule: `gone_home` is called from `process_card` and `restore_deleted`: read.
  - Restamp: `modified` = now, by `{name: merge, ... session: "merge"}`, on a trash arrival only. A card a person trashed on one side keeps its stamp (s5: ours trashed X then removed the lane, theirs edited X later → `.trash/X` keeps bob's stamp, both directions): measured. Rows TR1, TR2 and TT pass in the gate's `merge`/`rebase`/`nodriver` modes: measured.
  - Idempotent: a second `merge-board.sh` on the same tree reports "0 unmerged board paths resolved", and the file hashes and `git status` are byte-identical (no second restamp, no second comment): measured (s1, merge and rebase).
  - Report and comment say why; no lane uuid prefix in any report I produced: measured.
  - `index-less identity folders 0` and no folder left for a removed lane: measured whenever the lane held nothing of a person's (see notes 2 and 3 for when it did).
- **Data loss in the prune**: `prune` only runs `os.rmdir` on empty folders (read). Measured in s1: an untracked comment draft inside a conflicted card moved with the card into the trash, an untracked new card folder and an untracked `draft.txt` in the lane both stayed, and an unchanged card the remover deleted stayed deleted (git's clean result). s2: a lane `index.md` re-created untracked before the pass → the lane counts as live, the card stays in it, nothing is pruned, and the board validates.
- **`gone_home`**: the trashed lane copy still wins (s3: git finishes it alone by rename, edit kept); liveness, not side, decides; collision → note 1.
- **Project conduct**: separate commits for board and skill; the board write is the fixer's comment only; no "assume Y" shapes. `rules.md`: the rule in one row (line 50), the restore row points at it, the Limits re-homing entry is extended (line 79), telegraphic, nothing restated.
- **Both paths**: merge, rebase (ours and theirs swapped) and cherry-pick each handled; measured.
- **Fail-before**: OWN RUN agreed with the fixer's. The branch's `tests/merge-case.sh` against the merge-base `lanework-merge.py` fails `lanegone` with "merge: G1 is not in .trash/" and `deleteadd` with "merge E6: not restamped by the pass".
  - Mutations on scratch copies, each run in `lanegone`, all red: `gone_home` with no liveness check → "G1 is not in .trash/"; the lane prune dropped → "a folder is left for the removed lane APPROVED"; `restamp` a no-op → "G1: not restamped by the pass"; the `LANE_GONE` line dropped → "G1's merge comment doesn't say its lane was deleted".
- **Test adequacy**: the `lanegone` mode is named, listed and smoke-lined like its neighbours; it has G3 as the no-restamp control and covers both phases.
- **Blast radius**: 4 skill and test files, as the card's Scope table lists; the `survivor` return change is used only by `restore_deleted`; no unexplained churn.
- **Population**: gate `--only merge`: "smoke: 16 passed (sections: merge)", exit 0, with 0 `not ok` over 16 cases, among them all 13 `merge-case.sh` modes. Gate `--only static,headers,usage_guard,plugin,versions,cite_as,release_gate`: "smoke: 28 passed (sections: static, versions, headers, release_gate, cite_as, usage_guard, plugin)", exit 0. Both ran concurrently on the worktree; `braces` was skipped as instructed.

**Hypotheses**, written before reading the fixer's record ([c20d87bd](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c20d87bd-ca46-47fc-ac2c-08f476f72022)). 2 of 8 held, both as notes.

1. The lane prune deletes a person's file: refuted (it only removes empty folders; s1).
2. A card newly added to the removed lane goes unhandled: held, before this branch too (note 2).
3. A card id already in `.trash/` gets overwritten: held for an untracked file (note 1).
4. The restamp reaches a card a person trashed: refuted (s5, TR1/TR2/TT).
5. A second run restamps or comments again: refuted (s1).
6. A rebase lands the card differently: refuted (`lanegone` rebase phase, s1, s7).
7. With both other locations gone, the card falls back into a gone lane: refuted (s7).
8. A lane `index.md` re-created untracked gets pruned, or its card moved: refuted (s2).
