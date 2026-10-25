---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:47:28Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T10:47:28Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**FAIL-BEFORE: the new lint-ask cases fail against the unchanged scripts at `a09634d`.**

**Evidence**: the lint-ask block of `tests/smoke.sh` extracted and run in `.claude/worktrees/recap-option` before any script edit. The two old cases pass; the new one stops on the card's observable.

```sh
ok 1 - lint-ask passes a clean ask
ok 2 - lint-ask fails a hedged, chained ask
lint-ask passed options without the Recap line
```

**Note**: the 79-word and no-options cases pass at the merge-base by construction, so they are guards against an over-strict lint, not fail-before. The discovery case (`file-question.sh` output lints clean) cannot fail until the lint requires the line.
