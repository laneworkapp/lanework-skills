---
schema: 1
kind: comment
created:  {at: 2026-11-20T21:51:33Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-20: built, reviewed and approved, merged to `main` at `2a5cceb`. Smoke on main: 266 passed.**

- **What changed**: `work/scripts/lint-waiting-clears.sh` (a `--since <UTC time>` flag, and the five lint edges), `work/references/writing.md` (the trial-ending sentence), `tests/smoke.sh` (the lint block), `README.md` counts. Branch head `54a5c4d`.
- **Ruling 1, count only clears made after 0.9.0**: met by `--since`. Without the flag the three earlier clears still print. A clear exactly at the `--since` time is listed.
- **Ruling 2, discovery writes the work quote format**: built on its own card, already merged.
- **Review: approved, round 1.** No blocking findings.
- **Each changed case can fail** (reviewer's own runs): against the script before the change, the three `--since` listing cases and the shortcut, fractional-seconds, fenced-quote, no-colon-Given and one-line quote-plus-Given cases all fail. The two that pass on the old script (the bad-value case and the body-`waiting` case) fail under a mutation of the fix.
- **`--since` values**: exit 2 with a message for fractional seconds, an offset, lowercase `z`, a date only, an empty value, the flag twice, the flag with no value. The pattern is not checked against the calendar, as the body accepts. The comparison is a string compare, correct for the whole-second `Z` stamps the app and the skills write.
- **Done when**: every line met. `check-refs: 243 references, 0 missing`; `check-sizes: 57 rows, 0 wrong`.
- **Changed after review, by the lead** (`54a5c4d`): the trial-ending sentence said the release time comes from a `stable` tag. `stable` is a branch; the sentence now names the commit date of the `v0.9.0` tag.
- **Known and accepted**: a record whose stamp carries an offset is not counted and does not set the clear time; the boards hold one such stamp in about 22,500. A comment stamped `kind: Agent` with a capital now reads as other, not human; the app never writes it.
- **Smoke under load**: no run on the branch reached its last line; four runs stopped at plan-claim timing cases this branch does not touch, after all 19 lint cases had passed. The run on main passed first time at load 19.
- **Owner step at release**: when 0.9.0 is cut, the trial is counted with `lint-waiting-clears.sh <board> --since <commit date of the v0.9.0 tag, UTC>`.
- **Bump**: minor (a new flag); rides 0.9.0.
- **CHANGELOG sentence**: "The waiting-clear check can now count only clears made after a given release time, and no longer counts a shortcut's comment, a quote inside a code fence, or a Given line without its colon."
