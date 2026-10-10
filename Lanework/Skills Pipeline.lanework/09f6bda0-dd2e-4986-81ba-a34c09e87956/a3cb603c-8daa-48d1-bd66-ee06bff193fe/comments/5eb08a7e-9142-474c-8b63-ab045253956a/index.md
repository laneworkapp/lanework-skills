---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:53:46Z, by: {name: reviewer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:53:46Z, by: {name: reviewer, kind: agent, model: sonnet}}
---
**Review: APPROVE (standard, round 1). `readme-sizes` at 8bba07f meets done-when; no blocking findings.**

```
VERDICT: APPROVE
STANCE:  STANDARD (no adversarial trigger: test script plus README numbers, no board writes, no persisted data)
ROUND:   1

CARD:   Ideas/Active a3cb603c, README sizes drift: generate or check the word counts
BRANCH: readme-sizes at 8bba07f

BLOCKING: 0
  none

NOTES: 1
  tests/check-sizes.sh @ 8bba07f "set -- $sl": clobbers positional params inside the loop; harmless today (no later use of $1..), a named read would be sturdier.

CHECKED:
  correctness vs done-when: OWN RUN, smoke case 62 passes on the refreshed README (smoke: 66 passed). Scratch copy outside the repo, run under /bin/bash 3.2.57: (1) finding.md row 351->350 -> "lanework/references/finding.md: README says 350, wc -w says 351" + "lanework/total: README says 3664, sum of rows says 3663", exit 1; (2) unlisted watch/references/extra.md -> "watch/references/extra.md: no README row (wc -w says 3)", exit 1; (3) watch total 1,254->1,255 -> "watch/total: README says 1255, sum of rows says 1254" + summary line, exit 1. Spot-check wc -w: lead.md 977, finding.md 351, watch SKILL.md 162, all equal README.
  project conduct:          stage-by-path files only, no skill text touched, bash 3.2 and BSD tools only (awk, wc, cut, grep, no GNU flags); CLAUDE.md tests row and Verified line updated. No assume-Y shapes.
  both paths:               row wrong, missing row, bad total, bad summary column all covered; missing file and missing summary/total rows fail loudly. Parser depends on README table shapes (fixer flagged); a shape change fails with "no § Sizes tables" or per-row errors.
  fail-before:              FIXER RUN checked (lead.md 976 vs 977 at 429f243, 1 of 47 rows); the three breakages reproduced by OWN RUN above. The assertion would fail on a wrong count.
  test adequacy:            helper sits beside check-refs.sh, called from one smoke case, same naming style.
  blast radius:             README 3 numbers (lead.md, work total, work summary), CLAUDE.md 2 lines, 2 test files; matches Phase-1. The card's "9 of 45" stale rows were already fixed on main; 47 rows now.
  population:               47 rows checked, 0 wrong on the branch.

UNRESOLVED: none. Merge reminder: re-measure the README refresh if 2191c5bc lands first (its skill edits move counts); the check will name any row that moved.
```
