---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:54:30Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:54:30Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and green at 0989f82 on `watch-reread`: `--skills` shipped with three smoke cases; mutations caught.**

- **Gate**: `env -u CLAUDE_MODEL bash tests/smoke.sh` → exit 0, `smoke: 84 passed` (ok 38 no-`--skills` unchanged, 39 live edit once, 40 non-rule edit silent, 41 restart reports at start, second restart silent). Run green 4 times in a row, no flake.
- **Sizes**: `tests/check-sizes.sh` → `48 rows, 0 wrong`. `arming.md` 339→377, `events.md` 399→453, watch total 1,254→1,346.
- **Mutations (scratch copies)**: root left out of fswatch → live case fails; start check removed → fails; fingerprint over every `*.md` → non-rule case fails; stored value never updated → the once check fails (`SKILLS CHANGED` repeats).
- **Not distinguishable by design**: a restart check that fires on the first burst instead of at start. Both report after a restart.
