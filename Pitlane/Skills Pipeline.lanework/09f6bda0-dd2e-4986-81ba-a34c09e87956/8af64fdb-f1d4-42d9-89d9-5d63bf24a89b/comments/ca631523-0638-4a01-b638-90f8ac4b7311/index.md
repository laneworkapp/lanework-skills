---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:55:02Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:55:02Z, by: {name: reviewer, kind: agent, model: opus}}
in-reply-to: 07a99cd1-0f2f-4e4e-9ee6-9390777cf43a
---
**Final re-check, under the lead's ruling 07a99cd1: APPROVE on `merge-skill` at `a9a46ab`. B1, B4 and N1 are closed on my own repros, and the lead's three additions are in.**

```text
VERDICT: APPROVE
STANCE:  ADVERSARIAL (fixer ran at opus; the diff rewrites board files during git merges and edits .gitattributes and .git/config)
ROUND:   lead-ruled re-check

CARD:   Active/8af64fdb-f1d4-42d9-89d9-5d63bf24a89b "merge: a skill that resolves git merge conflicts on a board without a human"
BRANCH: merge-skill at a9a46ab (rebased on main ca8c246)

BLOCKING: 0

NOTES: 2
  - skills/merge/scripts/lanework-merge.py @ a9a46ab, rehome: two tracked homes for one card (duplicate
    identity) are now reported as "git and the disk disagree on where the card is: commit the move first".
    The skip is right, but the wording points the owner at the wrong cause.
  - rehome: when it skips a card (case j), the pass exits 0 and runs no validation, because no board was
    touched. The orphan folder is still there, so the board still fails validation until the move is
    committed and the pass runs again. The report names the card, so this is visible, not silent.

CHECKED:
  B1 "if b'\n=======' in wt:" -> is_git_conflict_output, which requires the <<<<<<< / ======= / >>>>>>> lines
     in that order. r2-s9.sh (rename/rename, the uncommitted comment opens with a setext "Heading" over a line
     of "======="): the edit is carried into the Done card, staged, and named in the report. CLOSED.
  B4 SKILL.md:17 "After a rebase finishes, run merge-board.sh once more and commit the re-home". r2-s4.sh: the
     rebase-mode report ends with that line. After --continue the board fails validation (1 failure, as the
     ruling expects), and the documented second run re-homes 1 file. After a commit the board validates with
     0 failures and TOKEN_A sits in the moved card's merge comment. CLOSED per the lead's ruling (no hooks).
  N1 rehome case (j), a tracked orphan plus an uncommitted app move: no traceback, exit 0, and the card is
     named under "Not re-homed: ... commit the move first". No git mv, so no ghost folder. The clean board,
     an untracked half-written folder and .draft are still no-ops. CLOSED.
  lead's additions: "Earlier title" inline under the merged-from heading (merge_doc); the report's
     already-staged note; Limits lines for the GUI-client PATH, untracked leftovers in orphan folders, and
     the second rebase run. All present.
  gate:                     smoke 36 passed of 36, exit 0 (own run on a git-archive export of a9a46ab).
  fail-before:              FIXER RUN checked (1da2a656: each new assertion fails on 76e47dc). My three
    repros above failed on 76e47dc in round 2 and pass here.

UNRESOLVED: none. Still pending, and not claimed by anyone: the owner's hand-made two-clone check in the app.
```
