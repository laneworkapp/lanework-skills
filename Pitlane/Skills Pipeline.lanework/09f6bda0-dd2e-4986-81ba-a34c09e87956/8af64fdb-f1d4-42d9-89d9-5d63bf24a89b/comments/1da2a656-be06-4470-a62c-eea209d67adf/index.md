---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:52:56Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:52:56Z, by: {name: fixer, kind: agent, model: opus}}
---
**Round-3 fixes for the lead's ruling on verdict 780ff2a5: smoke is green at `a9a46ab` with 36 passed. Each new assertion fails on `76e47dc`.**

- **B1** (`skills/merge/scripts/lanework-merge.py`, `is_git_conflict_output`): a file counts as git's own conflict output only when it has `<<<<<<< `, `=======` and `>>>>>>> ` lines, in that order. Anything else is carried as an uncommitted edit. The dirty case's comment now opens with a setext heading.
- **B4**: in a rebase, the report ends "After the rebase finishes, run merge-board.sh once more and commit the re-home." `SKILL.md` step 4 says the same. The `rebasemove` case asserts that line at every stop. Its control asserts that the board fails validation after `--continue`. It then runs the second pass as the flow, commits, and validates.
- **N1**: rehome reads the card's home from disk. A card whose index and disk disagree is skipped and named in the report. Errors are caught per card. New case (j): a tracked orphan, plus an uncommitted app move.
- **Lead's calls**:
  - a lane or board title changed on both sides goes inline as `Earlier title: "…"` under the merged-from heading (asserted in `clean`)
  - the report notes already-staged changes mixed with a re-home (not tested)
  - `rules.md` Limits now has the GUI-client PATH note, untracked leftovers in orphan folders, and the second rebase run
- **FAIL-BEFORE on `76e47dc`** (measured): [fail-before-round3.txt](attachments/28a88abf-d157-43bc-93e8-bb212f5dcaaa/blob.txt). Each run exits 1:
  - `dirty`: "the uncommitted edit was erased"
  - `rebasemove`: "the report doesn't say to run the pass again"
  - `clean`: "lossless merge: git should finish by itself", because the old driver stopped on the lane title
  - (j), with the title change removed so the run reaches it: a FileNotFoundError traceback from rehome, then "(j) was not skipped and reported"
- **Gate** (measured): exit 0, "smoke: 36 passed". Raw: [smoke-gate-round3.txt](attachments/0e058256-e918-44e2-8590-f0ed8218b155/blob.txt).
