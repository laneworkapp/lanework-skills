---
schema: 1
kind: comment
created:  {at: 2026-11-07T13:21:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-11-07T13:21:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Reviewer verdicts are read for the decision, the findings and a little evidence, and half their words are a check walk almost nobody cites.** The proposal is in the body. Two calls follow as asks.

- **Evidence, population**: all 647 comments with a `VERDICT:` line on the Lanework Pipeline board, out of 9,496 comments, 2026-09-01 to today. `.trash` excluded. Counted by script, so section splits are approximate on older verdicts that drift from the template.
- **Utility, what earns its place**: 171 of 643 verdicts with a readable result were REQUEST-CHANGES, so review changes outcomes. 229 links from other comments point at a verdict, and a sample of 14 cites its result, its findings or a measured run.
- **Utility, what doesn't**: 3 of those citing comments name CHECKED or the hypotheses (a word match, not read one by one). No skill file reads CHECKED. The owner has never replied to a verdict by `in-reply-to`, and 105 of 647 have any owner comment after them on the card, so the reader is the lead and later agents.
- **Verbosity**: reviewer is the biggest author on the board, 815,420 of 2,665,916 words from 806 comments. Verdict median 889 words, p90 1,674, max 4,870. A plain APPROVE has a median of 772. CHECKED has a median of 485 and holds 328,308 of the 645,182 verdict words. The median has fallen from 1,045 in September to 783 in November with no rule asking for it.
- **Formatting**: 456 of 647 are one fence, because the template is one. The fence has its own hard line breaks, 8,560 of its 26,368 lines pass 100 characters, and a card-width column wraps them again, which is the jagged text in the screenshot. Nothing renders inside it: 642 of 647 carry bare eight-hex ids, and 17 fences hold a link that can't click. 427 of 647 open with a bold line the template doesn't ask for, because `work/references/writing.md` § The record does, so they state the result twice. `CARD: Active/…` also goes stale: the screenshotted card now sits in Done.
- **Buried**: 248 of 596 UNRESOLVED sections hold more than "none", and they come last, under the walk.
- **Decided**: keep the nine-item review checklist and the adversarial read order as they are. Only what gets reported changes. Keep `file:line @ sha "fragment"`, the population beside every zero (E1), and the head read off the branch (E9).
- **Decided**: the opening `**Verdict: APPROVE.**` stays greppable. No script or app source reads `VERDICT:`, so nothing breaks.
- **Decided**: old verdicts stay as written.
- **Rejected**: keep the fence and only cap the words. Links, emphasis and the double wrap would stay broken.
- **Rejected**: a one-line result with no evidence. The fail-before run and the gate population are what later comments cite.
- **Accepted limitation**: a short report is easier to claim falsely than a long walk. The attached trace and the fail-before run are what remain against that, and later review quality can only be watched, not gated.
- **Evidence, gate today**: `tests/smoke.sh` stops at the guide gate, board guide v107 against stamp v101. Its other checks shown (through 123) pass. [2c29a34f](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2c29a34f-fde2-4a44-8a3b-94157a320609) clears that, so the done-when needs it landed or the gate failure named.
- **Retitled** from "formatting issue", since the review reaches past formatting.
