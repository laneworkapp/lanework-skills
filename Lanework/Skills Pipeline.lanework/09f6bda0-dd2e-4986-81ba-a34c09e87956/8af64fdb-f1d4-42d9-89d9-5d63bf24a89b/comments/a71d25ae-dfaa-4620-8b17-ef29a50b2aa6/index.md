---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:34:14Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T10:34:14Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
**START: building route A, the `appside` mode, on branch `merge-appside`. Taken from the top of Approved into Active; this dispatch handler leads it.**

- **Branch**: `merge-appside`, worktree `.claude/worktrees/merge-appside`, off `origin/main` at `f9ba99c`.
- **Team**: a sonnet fixer builds it (tightly specified tests), a sonnet reviewer at standard stance.
- **Scope**: the body's Touches (A) and Done when (A). No change under `skills/` expected.
- **Merge order**: branch `type-kind-cube` also touches `tests/smoke.sh`. Whichever lands second rebases and re-runs smoke.
- **Gate note**: the app upgraded this board's guide to v101 in the working tree, uncommitted. Smoke's stamp gate reads it, so main is re-verified on a clean checkout of the committed tree. The v101 bump is its own work.
