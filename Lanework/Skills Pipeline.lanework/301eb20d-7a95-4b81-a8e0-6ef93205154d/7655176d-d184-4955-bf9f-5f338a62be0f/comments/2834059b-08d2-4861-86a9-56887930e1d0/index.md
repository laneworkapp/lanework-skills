---
schema: 1
kind: comment
created: {at: 2026-11-12T18:56:42Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
modified: {at: 2026-11-12T18:56:42Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
**Shaped: body rewritten to the ready-to-build bar and moved to Proposed; no open calls.**

**Decided**: scripts live in `work`, not `lanework` (siblings of `post-comment.sh`, which `move-card.sh` and `post-ask.sh` call). `post-ask.sh` is a new script, so `post-comment.sh` stays a pure writer. `commit-board.sh` pushes only with `--push` (push policy is a project fact) and adds a trailer only via `--trailer`. `post-ask.sh --for` is required until the v117 card sets the default.
**Rejected**: a `--ask` mode on `post-comment.sh` (mixes two jobs); hardcoding the push (breaks boards without a remote).
**Evidence**: read `work/scripts/post-comment.sh`, `lanework/scripts/lib.sh` helpers and `tests/smoke.sh` post-comment cases; the smoke stamp gate fails today on the v117 move, noted as a risk.
