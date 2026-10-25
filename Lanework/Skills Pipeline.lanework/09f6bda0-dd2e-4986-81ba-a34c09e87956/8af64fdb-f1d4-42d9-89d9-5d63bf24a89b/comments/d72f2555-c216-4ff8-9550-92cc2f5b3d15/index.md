---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:40:48Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:40:48Z, by: {name: fixer, kind: agent, model: opus}}
---
**Round-2 verification: smoke is green at `76e47dc` on top of main `7248f42`, with 36 passed. The three new cases each fail on round 1's `068c6b4`.**

- **FAIL-BEFORE** (measured): the round-1 tree was exported with `git archive 068c6b4`, and I ran the round-2 `tests/merge-case.sh` against it. Raw: [fail-before-round2.txt](attachments/249f7846-3a83-4bd4-9937-0a0393766c30/blob.txt). Each mode exits 1:
  - `clean`: "not committed: LANE_A_TOP", because git finished and dropped one lane edit.
  - `rebasemove`: "the losing pick should stop".
  - `dirty`: "the uncommitted edit was erased".
- **Gate** (measured): `bash tests/smoke.sh; echo $?` gives exit 0 and "smoke: 36 passed". That's main's 30 plus 6 merge steps. Raw: [smoke-gate-round2.txt](attachments/b30d1818-d95b-4f58-b468-b437eb241f62/blob.txt).
- **New cases**:
  - **clean**: a lossless merge that git finishes alone, with nothing untracked. Two non-overlapping lane edits merge, and overlapping ones end up inline. A comment posted against a move gets re-homed. A body loss against a move makes git stop, writes nothing untracked, and is then committed with exactly one merge comment.
  - **rebasemove**: B4's shape.
  - **dirty**: B1's shape, once as a rename/rename and once with the comment left merged.
- **Asserts added**: M1's order is 4000 (the later side). TR1's token is inside the trashed card. An unclassified board file keeps ours, with theirs beside it.
- **Correction**: my round-1 fail-before attachment didn't show the run it described. The shared scratch file had been overwritten before I attached it. This round's files are under a fixer-only folder.
- **PENDING, owner check**: the hand-made two-clone collision in the app. Not run.
