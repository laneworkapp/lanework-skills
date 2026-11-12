---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:31:49Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:31:49Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
in-reply-to: 7b32bf98-8917-42dc-ac44-f134273fe83f
---
**Round 2 of `guide-v114-2c29a34f` at b0d9665: APPROVE. The block-form `waiting` finding is fixed in both scripts and in frontier.sh, and each new smoke case fails on the old code.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (fixer ran at opus; Phase-2 blast radius differed from Phase-1)
ROUND:   2

CARD:   Active/2c29a34f "Skills target agent guide v114: waiting lists, short links, relations, component retired"
BRANCH: guide-v114-2c29a34f at b0d9665 (read off ls-remote), rebased on main 9450be4. Scope: the open BLOCKING finding plus the diff 25a7cbe..b0d9665. main moved no file outside Lanework/.

BLOCKING: 0
  Closed: settle-question.sh:43-45 and resolve-ticket.sh:50-52 @ b0d9665 "n==1 && drop && /^[ \t]/ { next }". OWN RUN: both awks, taken verbatim from the branch, were run on five cards. (1) my round-1 121-char card after compact_fm. (2) a block waiting then a top-level key. (3) a block as the last key, then the closing ---. (4) a block then order:, where order must still be replaced. (5) the flow form. All five parse after the run, with no waiting key, order and modified restamped, and an indented body line kept. frontier.sh waiting_set marks all five. It leaves unmarked an empty waiting:, a waiting: line in the body only, and no waiting at all.

NOTES: 1
  tests/smoke.sh:1135 @ b0d9665 "guide[^.]*[^[:alnum:]_-]v[0-9]+|(^|[^[:alnum:]_-])v[0-9]{2,}": the new floor check has no positive control in the run (E3). A broken pattern would pass green, and the only control was the fixer's one-time run at 25a7cbe. It also scans .md files only, so a floor in a script comment passes. Measured against 12 strings: it flags "guide line reads v105+", "the guide's v114 copy" and "a v12 board". It passes "schema v1", "v0.8.0", "v10.2.1" and "HEAL.md catalog v2→v5". No false hit on today's skills tree.

CHECKED:
  correctness vs done-when: the round-1 failure scenario, re-run on the branch scripts: clean (above).
  project conduct:          writing.md:50 is version-free ("only where the board's guide § Mentions allows a list"). lib.sh is untouched. No board files in the branch diff.
  both paths:               the flow and block layouts of waiting, in all three scripts.
  fail-before:              FIXER RUN checked (fail-before-round2.txt): the settle, resolve and frontier excerpts, the lint-ask case and the version check each fail at 25a7cbe. The root-key-mapping case restores coverage and passes there, as stated. REASONED, agrees: the old awk leaves the "  for:" lines that the new grep -E '^(waiting:|  (for|since|comment):)' catches, and the old fm_value reads a block waiting as empty.
  test adequacy:            the settle assertion is now "{ ...; } || exit 1", so it can fail under set -e. The awk -v WBLOCK writes real newlines, checked by the grep on '^  for: \[rzen, bobsmith' that follows it. The card-0b root-key case greps the dry-run line and the flowed entry.
  lint-ask:                 OWN RUN, 12 inputs at b0d9665. These still fail: a bare @bob off line 1, @bob after a code span, after an unclosed backtick (the strip runs per line and never across lines), after a URL, in link text, after a lanework:// link, after "Note:" and after "mailto:". These pass: @ in a code span, in a ](target), and in a bare scheme:// URL.
  blast radius:             7 files: the round-1 finding and the lead-directed NOTE fixes. No unexplained churn.
  population:               my lint-ask set: 12 inputs, 12 as expected. awk cases: 5 cards x 2 scripts, 10 of 10 parse. waiting_set: 8 inputs, 8 as expected.
  adversarial only:         hypotheses: the drop flag leaks into the body or eats the key after the block. Refuted. An unclosed backtick swallows a handle. Refuted. The version pattern false-flags semver or the schema stamp. Refuted.

UNRESOLVED: none
```
