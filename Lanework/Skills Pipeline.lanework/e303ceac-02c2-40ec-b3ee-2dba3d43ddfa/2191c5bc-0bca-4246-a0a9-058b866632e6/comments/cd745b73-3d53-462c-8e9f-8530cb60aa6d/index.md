---
schema: 1
kind: comment
created:  {at: 2026-10-10T03:13:48Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T03:13:48Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review, round 2: APPROVE on `label-kinds` at 7e0e571. Both BLOCKING findings are fixed, and the three ruled-in notes are done. Smoke passes 79 of 79, check-sizes finds 0 wrong of 48 rows, and heal gives the same output as main on all 334 real board copies.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (found-board.sh writes board config; heal-board.py rewrites label stamps on users' boards, which is persisted data)
ROUND:   2

CARD:   Proposed/2191c5bc "lanework: a catalog of common label kinds for founding boards"
BRANCH: label-kinds at 7e0e571 (rebased onto origin/main, merge-base 912b27b; round-1 head 1e8a8e0 = c251639 after rebase)

BLOCKING: 0
  B1 closed: skills/lanework/scripts/found-board.sh @ 7e0e571 "[ -n "$HAS_LABELS_SLOT" ] || { echo "found-board.sh: --labels given but $INDEX
    has no {{labels}} or {{label_entries}} slot" >&2; exit 2; }". Re-ran the round-1 repro (slotless index + --labels priority):
    rc=2, no board folder. The check runs before mkdir. A slotless index without --labels still founds (smoke).
  B2 closed: skills/discovery/scripts/found-discovery-board.sh @ 7e0e571 "LABELS=round" ... "[ "$k" = round ] || LABELS="$LABELS,$k"".
    Re-ran the repro --labels priority: config.labels = round, priority, record, status. And found-board.sh @ 7e0e571
    "needs --labels (it holds {{label_entries}})": discovery/templates/board.md without --labels -> rc=2, nothing written.

NOTES: 2
  skills/discovery/scripts/found-discovery-board.sh @ 7e0e571 "if [ "$1" = --labels ]; then EXTRA="${2?...}"": a second --labels replaces the
    first (--labels type --labels size -> round, size; type dropped, rc=0). found-board.sh has the same last-wins rule, and round
    survives either way.
  same file @ 7e0e571 "if [ -n "$EXTRA" ]": --labels "" is accepted as round only (rc=0), where found-board.sh --labels "" exits 2.
    Harmless, just inconsistent.

CHECKED:
  correctness vs done-when: B1/B2 re-checked by quoted text and by re-running both round-1 repros. Edge cases tried by hand:
    positional title + --name + --labels (passes through, stamps nn), pipeline --var project/verified + 3 kinds (founds, validates).
  project conduct:          one plain commit on top of the rebased two, skills/tests/README only, no board writes.
  both paths:               discovery round via the wrapper (merged) and via found-board.sh directly (refused). Slotted and slotless
    templates, with and without --labels, are all covered.
  fail-before:              not re-run (round 2 is scoped). The round-1 OWN RUN stands. The new cases fail on 1e8a8e0 by construction:
    they assert exit 2 where it exited 0.
  test adequacy:            5 new smoke cases sit in the label-kinds block beside their neighbours. Discovery --labels over
    priority / priority,round,type / round. Discovery template without --labels. Slotless with and without --labels.
    Duplicates "type,type" and "priority,size,priority" (round-1 note). Each reserved --var (labels, label_entries, title,
    title_yaml, id, stamp) exits 2 and writes nothing (round-1 note).
  blast radius:             since c251639: README, found-board.sh, found-discovery-board.sh, smoke.sh (tests/check-sizes.sh came from main).
    heal-board.py and the catalog are unchanged. No churn outside the findings.
  population:               README Sizes: lanework 10 files / 3,995 words, label-kinds.md 249 listed (round-1 note). check-sizes.sh:
    48 rows, 0 wrong. Smoke 79/79 in the scratch worktree at 7e0e571. Heal dry run, main (912b27b) vs branch vs lone branch copy,
    --ignore-board-copy, on rsync copies of all 334 *.lanework under ~/Indie: 0 diffs. 9 discovery/grill boards: stale-label 0.
  adversarial only:         round-2 hypotheses: --var guard clobbers positional args (no, they are consumed first); the reserved
    list breaks an existing caller's --var (no, callers use topic/project/verified only); BSD grep treats {{ as an interval (no,
    smoke and the repro pass); discovery wrapper mis-parses other flags (no); repeated or empty --labels (HELD, notes only).

UNRESOLVED: none
```
