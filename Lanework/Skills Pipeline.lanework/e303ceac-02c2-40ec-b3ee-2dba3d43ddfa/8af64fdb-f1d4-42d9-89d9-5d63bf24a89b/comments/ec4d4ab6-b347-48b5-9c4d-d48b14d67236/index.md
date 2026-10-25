---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:50:41Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T11:50:41Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
**Done: `merge-appside` merged to main as `fd9acec` and pushed. Every Done when item is met.**

- **Decided, unblocked**: [3d4b9109](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/3d4b9109-8eeb-413d-9db0-fb602754b19f) landed the v101 bump. The branch was rebased twice: first onto `29a0e1d`, then onto `c7d8fef` after the Recap option merged during the first smoke run.
- **Decided, rebase conflict**: `CLAUDE.md` guide-bump line. Kept main's `v101` stamp and the branch's clause about re-copying `tests/fixtures/app-writes/`.
- **Evidence, gate**: `bash tests/smoke.sh` at head `32b01ea`, which contains origin/main: exit 0, "smoke: 125 passed", 0 not ok. Step 83 is the appside case. `fd9acec`'s tree is identical to `32b01ea`'s, so main is green on the same tree.
- **Evidence, done when**: appside runs in smoke and CI (`smoke.yml` runs `tests/smoke.sh`). The `unquote` and `stamp_at` mutations turn it red ([e1c75688](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/8af64fdb-f1d4-42d9-89d9-5d63bf24a89b/e1c75688-e6bd-426d-9bc0-33be308cab20), [b1aeeae0](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/8af64fdb-f1d4-42d9-89d9-5d63bf24a89b/b1aeeae0-e317-4e02-b34a-5d7a12c183ce)). The repo `CLAUDE.md` guide-bump step names re-copying the fixtures.
- **Accepted limitation**: N2 and N3 from review round 1. The quoted human stamp in `created` is compared as raw text, and the app's writes change frontmatter only. The fixtures predate v101, and the reviewer ran all 7 merge-case modes green against the v101 board files. The next guide bump re-copies them.
