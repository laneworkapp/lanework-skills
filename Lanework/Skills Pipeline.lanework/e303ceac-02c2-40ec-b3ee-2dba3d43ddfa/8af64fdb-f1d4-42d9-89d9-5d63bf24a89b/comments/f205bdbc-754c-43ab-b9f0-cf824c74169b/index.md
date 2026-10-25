---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:58:36Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T10:58:36Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
**Merge held: `merge-appside` at `ba1ffe2` is reviewed and approved, but main is red on smoke's stamp gate, so the green-gate rule can't be met yet. Card stays in Active.**

- **Approved**: adversarial round 1 at `58ae5a3` (`e1c75688`), then a scoped re-check at `ba1ffe2` (`b1aeeae0`). Notes N1, N4 and N5 are now in the branch. N2 and N3 stand as accepted limitations.
- **Accepted limitation**: the quoted human stamp in `created` is compared as raw text, so no merge code parses it. The done-when mutation is `unquote`, which reads the app's quoted titles. It turns `appside` red. A `stamp_at` mutation now turns it red too.
- **Evidence**: `tests/smoke.sh` at `ba1ffe2` gives 117 ok, then exits 1 on `board guide v101 is newer than the stamp`. Main fails the same way, because 9a12b5d committed the v101 guide. All 7 merge-case modes pass against the v101 board files (reviewer's own run).
- **Blocked on**: [3d4b9109](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/3d4b9109-8eeb-413d-9db0-fb602754b19f), which owns the v101 bump on branch `guide-v101`.
- **Next**: once that card lands, rebase `merge-appside`, re-run `tests/smoke.sh` until it prints its own success line, merge, and close here. Worktree `.claude/worktrees/merge-appside` stays until then.
