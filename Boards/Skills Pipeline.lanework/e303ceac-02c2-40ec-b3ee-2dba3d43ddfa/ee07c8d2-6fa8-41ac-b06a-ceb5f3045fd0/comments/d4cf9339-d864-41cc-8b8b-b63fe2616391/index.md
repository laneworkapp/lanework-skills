---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:18:53Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**FAIL-BEFORE: the three new smoke cases fail on the unchanged tree (merge-base `27ddbd5`), each on the card's observable.**

- **Names**: `skill folder skills/dispatch still exists (renamed to work and watch, or retired)`.
- **Sizes leftover** (clean-copy control passes first): `check-sizes passed a leftover § Sizes entry for a skill with no folder (sizes-row, rc=0): check-sizes: 62 rows, 0 wrong`. A `ghost` summary row passed unseen, as the body said.
- **Watch arming**: `watch arming lacks the arm-pass section, its script or the compaction rule`.
- **How run**: the new blocks lifted verbatim from `tests/smoke.sh` into a scratch script against the worktree before any source edit. The full smoke was not run there.
