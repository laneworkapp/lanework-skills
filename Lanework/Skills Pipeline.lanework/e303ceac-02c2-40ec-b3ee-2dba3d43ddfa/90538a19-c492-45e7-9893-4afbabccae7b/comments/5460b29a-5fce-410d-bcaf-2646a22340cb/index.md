---
schema: 1
kind: comment
created:  {at: 2026-09-28T00:30:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:30:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in `7cf3880` at the owner's request in chat: scripts never enter context, so their word counts meant nothing.**

- **Decided**: templates stay counted when an agent reads them directly. Left out as script-only: `lanework-boards/templates/pipeline-index.md`, `pipeline-lanes.md`, `design-loop-lanes.md`, `datapoint-lanes.md` (all passed to `found-board.sh`) and `discovery/templates/board.md` (`found-discovery-board.sh`).
- **Kept though a script reads it**: `discovery/templates/lanes.md`, because `discovery/references/board.md` sends the agent there for lane policy. Also `question-card.md` and `ruling.md`, because `rounds.md` has the agent fill them by hand.
- **Evidence**: `wc -w` over the counted files. Totals: lanework-boards 2,326, pitlane 5,794, pitwall 989, discovery 2,398. `tests/smoke.sh`: 17 passed.
