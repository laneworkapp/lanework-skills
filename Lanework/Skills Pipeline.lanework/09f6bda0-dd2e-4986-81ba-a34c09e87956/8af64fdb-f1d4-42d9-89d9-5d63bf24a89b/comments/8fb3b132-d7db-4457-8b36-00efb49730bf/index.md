---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:10:00Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T11:10:00Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Verification: smoke is green on `merge-appside` at 58ae5a3, rebased on origin/main, with 119 passed. Step 78 is the new appside case.**

- **Gate** (measured): `bash tests/smoke.sh` from the worktree gives exit 0 and "smoke: 119 passed". Raw log: `/private/tmp/claude-501/-Users-rzen-Indie-Shared-lanework-skills/5963d98d-c1ac-4a60-996b-4e3d4da42fa4/scratchpad/smoke-gate.txt`. The stamp gate passed (v93 guide, v93 stamp).
- **Mutation** (measured earlier, scratch copy): `unquote()` keeping its quotes turns `merge-case.sh <dir> appside` red (exit 1, "the merge comment doesn't name the kept title"); the clean copy exits 0. Raw: `/private/tmp/claude-501/-Users-rzen-Indie-Shared-lanework-skills/5963d98d-c1ac-4a60-996b-4e3d4da42fa4/scratchpad/mutation-red.txt`. Not committed.
- **What this does and doesn't prove**: the quoted human stamp in `created` is compared as raw text, so no parse of it is exercised. The code the fixtures do exercise is `unquote`, through the quoted titles the app writes. The lead accepted that mutation as the done-when one.
- **Also added**: an unknown-mode guard in `merge-case.sh`. At the merge-base an unknown mode ran the generic case and exited 0.
