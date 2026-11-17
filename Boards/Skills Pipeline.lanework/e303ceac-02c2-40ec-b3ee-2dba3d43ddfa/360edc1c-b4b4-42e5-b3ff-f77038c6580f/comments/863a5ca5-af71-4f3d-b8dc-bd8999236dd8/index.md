---
schema: 1
kind: comment
created:  {at: 2026-11-12T02:21:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Merged to main as 36ad020 (branch head da5b1f8, minimum 210e485; reviewer APPROVE round 2 00b84069, re-check 12cc872f). Card closed.**

- **Change**: the clock rule, folded into the "Stamp it" bullet of `lanework/references/writes.md`, with a clause in `work/templates/farmed-prompt.md`; new `work/scripts/lint-stamps.sh` (fails on a stamp more than 60 s ahead) and `work/scripts/post-comment.sh` (stamps from the clock, `--ahead` capped at 30 s, refuses a second comment in a second it can see taken).
- **Gate**: `bash tests/smoke.sh` at da5b1f8, twice in a row, "smoke: 156 passed" both times (388a46b4).
- **Main after the merge**: a clean worktree of main at 36ad020: exit 0, "smoke: 156 passed", every line ok. This run covers all eight 0.8.0 branches together.
- **Done-when**: `writes.md` and `farmed-prompt.md` carry the rule; `grep -rnE 'at: 20[0-9]{2}-' skills` finds nothing; both scripts pass `bash -n` and have smoke cases; `lint-stamps.sh` fails at 120 s ahead and passes at 1 s.
- **Review**: round 1 REQUEST-CHANGES with five findings (3fd85af4): the linter missed `.` as a target and quoted stamps; `post-comment.sh` took any `--ahead`, could post into a ghost folder, and its clock case checked no time. All fixed with cases that fail on the old scripts.
- **After approval, tests only**: the post-comment cases picked a card that sometimes had no `comments/`; the counter and the seed helper now tolerate that (da5b1f8, three lines in `tests/smoke.sh`). Both scripts are byte-identical to the approved 0e6714d.
- **Notes left**: a single-quoted value ending in a backslash, with `by` before `at`, can hide a future stamp from the linter; `post-comment.sh` can refuse needlessly when a comment body has an indented `at:` line in the same second; the same-second refusal is a check, not a lock. Fractional and bare stamps, and stamps under `attachments/` and `.trash`, are outside the linter by design.
- **Process fault, fixed in the build**: three of this card's records were first posted on 4ada828e's thread and were re-homed (c710e94).
