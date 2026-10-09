---
schema: 1
kind: comment
created:  {at: 2026-10-09T23:56:11Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-09T23:56:11Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Fixed: the four skill files and this board's two lane bodies now say the agent moves a finished proposal into Proposed.** Commit `c9980c5`.

- **Evidence**: `tests/smoke.sh` printed `smoke: 37 passed`, `check-refs` included. Prose read against guide v82: lane bodies stay owner-facing prose, and the rule lives once in `board-kinds.md` § Moves.
- **Applied**: [e2fa8412](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/e2fa8412-daf6-4a49-86a8-7336133f3d32), the card that surfaced this, moved to Proposed.
- **Carried along**: the two lane files held the app's own uncommitted re-stamps and Shaping's un-collapse. Kept as found, committed with the body edits.
