---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:56:39Z, by: {name: reviewer, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T10:56:39Z, by: {name: reviewer, kind: agent, model: opus, session: "board dispatch"}}
---
**Review round 1 verdict: REQUEST-CHANGES. The discovery path now shows a Recap button but still reads any click on it as a ruling.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (fixer UNCERTAINTY not "none": option-detection heuristic)
ROUND:   1

CARD:   Active/5f372bd4-d140-46fa-9566-6ce1d628a728 "Standing Recap option on every ask"
BRANCH: recap-option at d351940

BLOCKING: 1
  skills/discovery/scripts/file-question.sh:65 @ d351940 "- Recap: Explain this in plain terms first\n\n": every
  discovery question ask with options now has a Recap button. The discovery rules for a click were left as
  they were, and they contradict the new click rule in work/references/writing.md:57 @ d351940 "re-post the
  same ask as a new comment". (a) skills/discovery/references/conduct.md:5 "Exactly one ask per question card
  ... No other comment mentions the handle": the re-post breaks that rule. (b) skills/discovery/SKILL.md:43
  "owner comment newer than waiting.since = unrecorded answer -> record it first", plus rounds.md § Answers
  and conduct.md:6 "Ruling = owner's words": so a resumed or watching discovery agent writes "Recap: Explain
  this in plain terms first" into ## Ruling and settles the card. Input: the owner clicks Recap on a Q card.
  Wrong result: the question settles on a non-answer, or a second ask is posted against conduct. Not flagged in
  UNCERTAINTY. Fix direction: in discovery (conduct.md, plus a pointer at SKILL.md Resume step 2 and
  rounds.md § Answers), say that a Recap: click is not an answer. Follow work/references/writing.md § The ask,
  and allow the re-posted ask as the card's one live ask (the older one becomes history). Or have the lead
  rule that discovery asks get no Recap line, and drop the line from file-question.sh.

NOTES: 3
  skills/work/scripts/lint-ask.sh:11 @ d351940 "last among them": the header claims a position check the code
  doesn't make. Line 28 only tests that the line is present, so Recap placed first passes (own probe: exit 0).
  The card and writing.md:54 both say "ends them with". Either check that it comes last, or drop "last" from
  the comment.
  skills/work/scripts/lint-ask.sh:28 @ d351940 "grep -q -x -F -e \"$recap\"": exact match, so a Recap line with a
  trailing space fails with "options lack the standing line" (own probe), which misleads. Any "- Note: x"
  bullet in an ask also counts as an option (own probe: fails). The guide says the app draws any "label:"
  item as a button, so this agrees with the app and is acceptable.
  tests/smoke.sh:496 @ d351940 "opt-full.md": the same bytes as opt-recap.md. A redundant fixture: use
  opt-recap.md to compute W.

CHECKED:
  correctness vs done-when: DW1 ask.md shape and example both carry the line. DW2 lint exit 1/0/0/0 matches
                            cases 49-51. DW3 file-question output has the line and lints clean (case 22).
                            DW4 writing.md holds the rule, and responding.md:7 only links to it. DW5 smoke is
                            green apart from the known stamp case, and README counts match (case 117).
  project conduct:          one topic, one file kept (the rule lives in writing.md). Telegraphic. Cites use
                            the <skill>/<dir>/<file> form. Board writes are in separate commits. No
                            "assume Y" shapes.
  both paths:               watch path linked. Discovery path not handled and not flagged: BLOCKING above.
  fail-before:              OWN RUN agreed. Branch tests/smoke.sh checked out in the scratch worktree at
                            3a91177: ok 1-48, then "lint-ask passed options without the Recap line", exit 1.
                            The fixer's a09634d differs from 3a91177 by board-only commits.
  test adequacy:            the new cases sit in the "work: lint-ask" block beside cases 47-48, named like
                            them, using ok/exit 1 the way the neighbours do.
  blast radius:             7 files, the same as Phase 1. The README diff covers only the three file rows
                            and the work/watch totals. No unexplained churn.
  population:               own run of a git archive of d351940: 119 ok, then the stamp failure, exit 1.
                            Base is 116 + 3 new = 119. check-sizes 62 rows / 0 wrong per the fixer (case 117 ok).
  adversarial only:         hypotheses written before reading the reports: H1 Recap order unchecked (held,
                            note). H2 exact match brittle on whitespace (held, note). H3 non-option "- X: y"
                            bullets misread as options (held, but it matches the app, so no defect). H4 Recap
                            line counted in the 80 words (did not hold). H5 file-question puts the line in
                            the wrong place or adds it to option-less asks (did not hold). H6 a second
                            consumer of clicks left unhandled (held: discovery, BLOCKING).

UNRESOLVED: whether discovery question asks should carry the Recap line at all. The owner's scope ruling
  covers "asks with options", and discovery asks have options, so the default reading is yes, with the
  discovery rules amended.
```
