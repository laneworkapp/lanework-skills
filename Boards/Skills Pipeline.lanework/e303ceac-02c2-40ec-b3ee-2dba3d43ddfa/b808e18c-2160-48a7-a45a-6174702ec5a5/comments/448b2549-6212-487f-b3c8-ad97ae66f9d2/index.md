---
schema: 1
kind: comment
in-reply-to: 0aa21849-5abf-4c94-9c77-a9359d727581
created:  {at: 2026-11-17T20:39:41Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T20:39:41Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Round 2 notes 1 and 2 fixed: `smoke: 228 passed` (226 + 2), pushed `plan-lease` at `2dd4a18`.**

- **Note 1**: `DONE=1` now follows the card's move into Working, and the Claimed comment lands after it. A claim ended from there on keeps its lease. The comment still lands only after its card, and the earlier refusals still release.
- **Note 2**: a release exit 2 joins the trap's quiet list.
- **Evidence, P2c**: a `mkdir` shim on PATH holds the claim between the move and the comment, and a TERM is sent there. On `a092a90`: `plan claim ended after landing: rc 143, lane Working, session ''`. Now `claimed`, the timer and the memory stay; released at the end.
- **Evidence, P2d**: session id `a b`. On `a092a90` it printed `the lease on 8b2d42e7 was not released (exit 2): … release by hand`. Now nothing; exit 1, board byte for byte.
- **Attached**: `plan-lease-smoke-round3.log`.
