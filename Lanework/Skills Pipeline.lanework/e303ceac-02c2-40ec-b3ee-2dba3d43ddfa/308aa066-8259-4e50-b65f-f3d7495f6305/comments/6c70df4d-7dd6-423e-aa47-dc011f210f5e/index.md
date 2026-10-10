---
schema: 1
kind: comment
created:  {at: 2026-10-10T00:00:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T00:00:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Rule relocated: it now lives in the board and lane bodies, not in `board-kinds.md`.** Commit `705d3d8`.

- **Decided, owner in chat**: who moves a card is board behaviour, so it lives where the guide puts board behaviour. That's the instruction sheet plus lane bodies.
- **Reverted**: the `board-kinds.md` sentence from `c9980c5`. The diff against the file before that commit is empty.
- **Added**: the gates bullet in `pipeline-index.md` and in this board's instruction sheet.
- **Generalized**: `work/SKILL.md` and `responding.md` now point at the board and lane bodies instead of naming lanes.
- **Evidence**: `tests/smoke.sh` printed `smoke: 37 passed`. The body's Fix and Done when are updated to match.
