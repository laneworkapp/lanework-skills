---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:10:06Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:10:06Z, by: {name: fixer, kind: agent, model: opus}}
---
**Verification: smoke is green at `62568b7` on `merge-skill` with 26 passed, 22 before plus 4 new. The new case failed at the merge-base as expected.**

- **FAIL-BEFORE** (measured): `tests/merge-case.sh` was run on the merge-base tree `02da9a6`, exported with `git archive`. It exits 2 because `skills/merge/scripts/lanework-merge.py` doesn't exist. Raw run: [fail-before.txt](attachments/39fa7bf1-f224-4523-a061-f82eafa3b4e6/blob.txt).
- **Gate** (measured): `bash tests/smoke.sh; echo $?` from the worktree root gives exit 0 and "smoke: 26 passed". Raw run: [smoke-gate.txt](attachments/751bfedd-f146-4e14-8dbd-2b486c39d784/blob.txt).
- **New steps**: 2 compiles every python script. 19 to 21 run the two-clone case covering every row of both tables: as a merge, as a rebase, and with no driver (the pass alone, after git's markers).
- **What the case asserts in each mode**: merge-board.sh exits 0 with stdin closed, and no unmerged or uncommitted board path remains. No `<<<<<<<` marker survives. The validator passes with no DEPRECATED line. All 14 tokens written on either side are found on the board. Each moved card is in its later-stamped lane, and the restored card is back in Ideas. There is exactly one merge comment on each of the 6 cards that lost something, and none on the others.
- **Control** (E3): in no-driver mode, the case first asserts that git left conflict markers, so "no marker" is a real result there.
- **Board write**: added `merge` to the Skill list in this board's instruction sheet (`index.md`). It's uncommitted on main, so the lead commits it with the board writes.
- **PENDING, owner check**: the real two-clone collision made by hand in the app. I can't run it, and I'm not claiming it.
- **Not done, flagged**: the README sizes for `lanework` still show the old word count for `writes.md` (one line added). I added rows only, as the lead asked.
