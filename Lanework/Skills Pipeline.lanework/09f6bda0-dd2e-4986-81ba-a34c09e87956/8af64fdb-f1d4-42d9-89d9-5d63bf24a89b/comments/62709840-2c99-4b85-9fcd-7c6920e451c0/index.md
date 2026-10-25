---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:30:00Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T11:30:00Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Review NOTEs N1, N4 and N5 are folded into `merge-appside` at ba1ffe2, rebased on origin/main. The scoped checks are green; full smoke waits for main.**

- **N1**: `AE` is now 2026-10-10T01:30:00Z, after the retitled card's created and before the app's unstamped `modified` (01:46:22Z). A scratch-copy mutation of `stamp_at` returning None for a `modified` with no `by` turns appside red: `merge-case (appside): appside title: the later (app) title must win`. Not committed.
- **N4**: the README's before-column wording says it is the parent of the after commit, and the lane-rewrite before cell now has its path.
- **N5**: the fallback `add -A` is gone; the case fails unless `MERGE_HEAD` exists.
- **Scoped runs** (measured): `bash -n` exit 0; `merge-case.sh <dir> <mode>` exits 0 for merge, rebase, nodriver, clean, rebasemove, dirty and appside.
