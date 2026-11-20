---
schema: 1
kind: comment
created:  {at: 2026-11-20T20:16:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-20: built, reviewed and approved, merged to `main` at `4125fd7`. Smoke on main: 256 passed.**

- **What changed**: `discovery/templates/ruling.md` (the chat record now has the work skill's shape: "Owner ruled off the board", a quote line, a `**Given**` line, and a link to `work/references/writing.md` for the rule), `discovery/scripts/settle-question.sh` (`--record` with no quote line or no `**Given**` line exits 2 and writes nothing), `tests/smoke.sh` (one changed case, one new), `README.md` counts. Branch head `cf0c2a5`.
- **Review: approved, round 1.** No blocking findings.
- **Done when**:
  1. a settled chat answer reads QUOTED in `lint-waiting-clears.sh`: met. On a fresh throwaway board the reviewer got `QUOTED 1, NO-QUOTE 0`.
  2. the old one-line record is refused, nothing written: met, exit 2, board byte-identical.
  3. `grep -rn "answered in chat" skills` prints nothing: met.
  4. smoke green: met on main, 256 passed.
- **Each new case can fail**: run by the reviewer against the script and template from before the change. The refusal case fails ("accepted an unquoted record"); the record case with the old-shape record fails with NO-QUOTE.
- **Built differently from the body**: the smoke case asserts the QUOTED line for that card, not the tally `QUOTED 1, NO-QUOTE 0`. The smoke board also parks a second question with no record, which the lint correctly lists as NO-QUOTE.
- **Adversarial inputs** (reviewer): refused with exit 2: an indented quote line, an empty file, a missing file. Accepted and read QUOTED: CRLF endings, `**Given**` inside the quote, a multi-paragraph answer.
- **Not fixed here, filed**: `settle-question.sh` clears `waiting` when no record is given, and accepts `--record` without `--reply`. Filed as [settle-question.sh clears waiting with no owner words recorded](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/264a81a7-0039-4dc8-b918-096827160c79).
- **Smoke under load**: the fixer needed four runs and the reviewer got none green on the branch, all while other smoke runs and Xcode builds loaded the machine (load average up to 406); failures were in plan-claim timing cases this branch does not touch. The run on main passed first time at load 15.
- **Bump**: patch; rides 0.9.0.
- **CHANGELOG sentence**: "Discovery now records an answer you give in chat in the same quoted format as the work skill, so it counts correctly as an answer."
