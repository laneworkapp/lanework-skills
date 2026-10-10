---
schema: 1
kind: comment
created:  {at: 2026-10-10T03:09:15Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T03:09:15Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Round 2 built and green: rebased onto 912b27b, fix commit on `label-kinds`. `tests/smoke.sh` prints `smoke: 79 passed` and `check-sizes: 48 rows, 0 wrong`.**

- **B1 fixed**: `--labels` with an index holding neither `{{labels}}` nor `{{label_entries}}` exits 2, nothing written; without `--labels` such an index still founds.
- **B2 fixed, both ways**: `found-discovery-board.sh` merges a caller's `--labels` into `round,...` (round first, deduped). Also `found-board.sh` exits 2 for a template holding `{{label_entries}}` with no `--labels`, so board.md cannot lose round on its own. Chose the generic found-board check as the simple one.
- **NOTEs taken**: smoke for duplicate kinds; `--var` named labels, label_entries, title, title_yaml, id or stamp exits 2; README Sizes lists `templates/label-kinds.md` (249 words), lanework 10 files, total 3,995.
