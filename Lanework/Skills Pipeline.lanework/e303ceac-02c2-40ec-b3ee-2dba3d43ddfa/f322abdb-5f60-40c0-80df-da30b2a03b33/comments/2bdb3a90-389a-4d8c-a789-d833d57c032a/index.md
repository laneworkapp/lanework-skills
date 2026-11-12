---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:09:42Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:09:42Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Verdict: APPROVE (round 1, standard stance) on `shaping-group-label-f322abdb` at 89ef072.**

```
VERDICT: APPROVE
STANCE:  STANDARD (fixer ran at sonnet; blast radius matched Phase-1; prose only)
ROUND:   1

CARD:   Active/f322abdb-5f60-40c0-80df-da30b2a03b33 "Shaping: assign a label from the kind the lane is grouped by"
BRANCH: shaping-group-label-f322abdb at 89ef072 (read off origin)

BLOCKING: 0
  none

NOTES: 3
  skills/work/references/sweep.md @ 89ef072 "Write it as a drop would: the flattened `labels` entry of K, stamped from the board's current `config.labels`": an open kind with no definition in config.labels has nothing to stamp from; say "or copy the stamp from the board card you took the value from". Never blocks: the card says the same.
  skills/work/references/sweep.md @ 89ef072 "Card has an entry of K → leave it": the guide matches kind case-insensitively and lets `group-by` legacy spellings read; an agent matching K literally could miss "Status" vs "status". Edge only, wording could add "any case".
  skills/work/references/sweep.md @ 89ef072 "Shaping lane `group: {by: label, kind: K}`": a lane sheet may still carry the legacy `group-by` mapping, which also reads; not covered, so the agent falls to "Nothing to do". Safe direction.

CHECKED:
  correctness vs done-when: compared against the card's rule bullet and the three rulings (7d30bca0 shaping only, 2bbea8c7 no due date, f088fd85 no priority) and the guide v114 group section. Shaping only, never priority (by or kind), never a due date, never overwrites an existing entry of K: all present. Four outcomes (already set, assign, unsure, nothing to do) named. The rule text is once under skills/ and the Shaping row points at it.
  guide agreement: `by: label` needs `kind` (nothing to do otherwise) ok; `kind: priority` reads as priority ok; closed kind lists values, open kind uses existing spelling ok; a drop writes the flattened labels entry in place of any the card had, rule writes the same and only when none exists ok; the trailing "No K" section named as in the guide ok; `kind` beside another `by` is ignored by the guide, the rule only acts on `by: label` ok.
  project conduct: telegraphic, one topic one file, no `<skill>/<dir>/<file>` citation needed within the skill; guide cited as "guide § Frontmatter, lanes", a heading that exists. No board-fact leaks into the skill.
  both paths: closed and open kinds, set and unset, grouped and ungrouped each handled. A single failure scenario (concrete lane group + card where the text does the wrong thing) was sought for each of priority, due, existing value and missing kind: none found.
  fail-before: FIXER RUN checked (grep at merge-base exits 1; check-sizes 543 vs 706 before README edit). Prose change, no script.
  test adequacy: smoke 125 passed per the fixer's log; I did not rerun the full smoke (heavy slot held elsewhere). check-sizes counts agree with the diff (sweep.md 706, work and summary 6,612).
  blast radius: Phase-2 matches Phase-1: sweep.md and README only.
  population: word counts have denominators in README rows; no other zeros claimed.

UNRESOLVED: none
```
