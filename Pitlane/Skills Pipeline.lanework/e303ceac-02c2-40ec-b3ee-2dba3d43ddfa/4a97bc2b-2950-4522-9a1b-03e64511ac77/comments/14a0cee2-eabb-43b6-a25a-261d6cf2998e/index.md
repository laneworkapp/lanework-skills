---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:55:15Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T22:55:15Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review of `guide-stamp` at a8e1f3c: APPROVE. Done-when is met, the gate fails closed on every bad input I tried, and the pointer card's audit justifies v82.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not "none": deleted SKILL.md heading, greedy stamp grep, number-only compare)
ROUND:   1

CARD:   Active/4a97bc2b "Guide version: drop the runtime check, make the stamp a release gate"
BRANCH: guide-stamp at a8e1f3c (merge-base dbb5dac)

BLOCKING: 0

NOTES: 4
  tests/smoke.sh:89 @ a8e1f3c "grep -r -l -E 'lanework-agent-guide v[0-9]+' \"$SK\"": only the exact guide form is guarded. OWN RUN on mutants placed under skills/: "lanework-schema v1", "Lanework-Agent-Guide v82", "lanework-agent-guide  v82" (two spaces) and "written against guide v82" all pass step 20. CLAUDE.md:29 says both stamps are "stamped here and nowhere else". Done-when names only the guide version, so this is not blocking. Fix direction: -i -E 'lanework-(agent-guide|schema) +v[0-9]+'.
  tests/smoke.sh:99 @ a8e1f3c "grep -o -E '[0-9]+$'": the schema parse is not anchored to "lanework-schema v", unlike BG on line 98. A trailing space or CR in VERSION gives "can't read the board's guide or schema version" (fails closed, but the message hides the cause). A "v1.1" would read as 1.
  README.md:138 @ a8e1f3c "Smoke fails when a board's guide is newer than the stamp": it is this repo's Skills Pipeline board, and its guide or schema. A user may read "a board" as any board they own.
  README.md:37 @ a8e1f3c "| `references/authority.md` | 164 |": now 129 words (lanework SKILL.md 319 -> 303, discovery SKILL.md 432 -> 422). The table is a dated 2026-10-01 snapshot and was already stale at dbb5dac (writes.md 759 vs 816), so this is pre-existing drift, not new.

CHECKED:
  correctness vs done-when: (1) git grep of skills/ at a8e1f3c for "v[0-9]+", "version", "§ Versions", "Versioning", "target" finds no guide version, only authority.md:5 "remembered version" and founding.md:23 "version marker". (2) CLAUDE.md:29 holds the one stamp of each, checked by the count on lines 91-94. (3) Smoke enforces both (steps 20, 21). No dangling refs: no file links "§ Versions" or the removed "## Versioning" headings; check-refs passes. The one line sits at the end of authority.md, worded as the body asks.
  v82 justification:        read the pointer card's (43456b82) thread: audit 0d86322f covers the text kind, kind stamping on every entry and the background mapping, and review 9f6039d7 approved it at 06e17f2 (merged d3d09b2). Own spot-check of the 3908fde guide diff vs skills/ at a8e1f3c: writes.md:10 matches labels-only priority/component and the text kind. The discovery Round label stamps its kind; no skill names "default" or writes a scalar background. board-kinds.md:26 "Group ... by component" stays valid (v82: grouping consults no definition). Nothing in skills/ contradicts v82.
  project conduct:          board writes are not in the code commit; one commit with a plain message; README § Versioning updated as Touches lists; the CLAUDE.md bullet is accurate and matches its neighbours' register.
  both paths:               guide and schema each gated (lines 101, 102); OWN RUN mutants: guide v100 > v82 fails, schema v2 and v10 > v1 fail, stamp v8 vs board v82 fails (numeric, not string). Board CLAUDE.md missing, whole board missing, empty VERSION, stamp not on line 1: all exit 1. Two stamps in CLAUDE.md, or none: exit 1. Stamp ahead of the board (v100 vs v82) passes, by design ("newer than the stamp"). Ran under /bin/bash 3.2.57 with set -euo pipefail.
  fail-before:              OWN RUN agreed: branch smoke.sh in scratch at dbb5dac, rc=1 at step 20 citing skills/lanework/references/authority.md. OWN RUN real-tree mutant: stamp v81 in CLAUDE.md at a8e1f3c, rc=1 "board guide v82 is newer than the stamp (lanework-agent-guide v81)". Scratch restored to dbb5dac, clean.
  test adequacy:            steps 20-21 replace the old version step in place, same ok/echo/exit style as their neighbours.
  blast radius:             six files, exactly the card's Touches list; no script, plugin.json or template churn.
  population:               full smoke OWN RUN at a8e1f3c (scratch, detached): rc=0, "smoke: 22 passed".
  adversarial only:         hypotheses before reading the reports: (1) refs to § Versions or "## Versioning" dangle: did not hold. (2) the v82 bump is unjustified or a skill still contradicts v82: did not hold. (3) the gate passes when wrong (string compare, unparsed line 1, missing board): did not hold, it fails closed. (4) the step-20 grep misses unusual forms: HELD (NOTE 1). (5) the greedy CLAUDE.md grep false-positives: holds only as a loud failure if CLAUDE.md ever mentions a second stamp in prose, which is acceptable.

UNRESOLVED: none
```
