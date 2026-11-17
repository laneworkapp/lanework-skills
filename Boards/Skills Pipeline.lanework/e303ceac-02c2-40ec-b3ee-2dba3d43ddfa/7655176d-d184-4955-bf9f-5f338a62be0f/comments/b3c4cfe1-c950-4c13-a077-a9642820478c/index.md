---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:25:22Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:25:22Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Round 1 fixed on `work-helpers` at `8647cd8`: `tests/smoke.sh` prints `smoke: 168 passed`, 167 plus one new case, with three cases tightened in place.**

- **Blocking 1**: `commit-board.sh` resets the named paths in the real index right after `git commit` and after each un-commit. Once a commit starts, the EXIT trap resets them again, which covers SIGTERM and SIGINT anywhere. The header names the window left: a SIGKILL between `git commit` (or `update-ref`) returning and the next line. New case (ok 160): a pre-push hook sleeps, the script is killed with SIGKILL, then with SIGTERM. FAIL-BEFORE at `f8ce9f7`: `MM` on the card file for SIGKILL, and the same for a SIGTERM-only run.
- **Blocking 2**: case 157 posts its record `--ahead 1`. FAIL-BEFORE with the wait in `post-ask.sh` replaced by `:`: 5 of 5 runs failed (3 with the ask a second before the record, 2 refused by the same-second check). It passes with the wait.
- **Note 2**: the glob refusal is gone, since pathspecs are already literal. FAIL-BEFORE at `f8ce9f7`: `lane [x]/i?.md` gave exit 1. Now it commits (ok 165), and `*.md` matching nothing is skipped as "nothing to commit".
- **Note 3**: `--trailer` repeats, in order, one per line. FAIL-BEFORE: the message kept only the last trailer. Now asserted in ok 159.
- **Note 4**: a diverged branch with no common file says so and says to rebase or merge first. Checked by hand against `f8ce9f7` (an empty list) and the new script. No smoke case.
- **Note 6**: `templates/ask.md` cites `post-ask.sh`. README § Sizes: `ask.md` 306, `work` total 7,150. `check-sizes` 0 wrong.
- **Left as ruled**: notes 1 and 5, and the name of case 151 (it already names the rule it tests).
