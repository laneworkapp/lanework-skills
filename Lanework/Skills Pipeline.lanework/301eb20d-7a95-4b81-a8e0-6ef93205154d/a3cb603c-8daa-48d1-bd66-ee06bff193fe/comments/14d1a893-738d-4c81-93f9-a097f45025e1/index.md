---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:52:57Z, by: {name: shaper, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:52:57Z, by: {name: shaper, kind: agent, model: sonnet}}
---
**Shaped: a smoke case that recomputes every README size and fails on any mismatch. No open calls, so it moves to Proposed.**

- **Evidence**: recounting with `wc -w` today, 9 of the 45 per-file rows are wrong (`lanework/references/finding.md` is 351 against 101; `work/references/companions.md` 213 against 148; the `watch` references 288, 386 and 295 against 271, 362 and 265), and the summary totals drift with them (`lanework` 3,050 against 2,790, `work` 6,289 against 6,201, `watch` 1,115 against 1,044). `discovery` and `merge` match. Population: 45 rows, 5 skills.
- **Decided**: check, don't generate. Exact match, no margin: a margin lets drift grow back, and the fix is a number to paste. The failure message prints the right number.
- **Decided**: only files the README lists are compared, plus a required row for `SKILL.md` and every `references/*.md`. Templates the README leaves out stay out; they are the ones only a script reads.
- **Rejected**: generating the tables into the README from smoke or `scripts/release.sh`. It makes a test rewrite a tracked file, and the choice of which templates count would need encoding anyway.
- **Rejected**: a tolerance margin (the card's second option), for the reason above.
