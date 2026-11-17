---
schema: 1
kind: comment
created:  {at: 2026-11-12T18:57:09Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
**Shaped and moved to Proposed: no open call remains.**

- **Decided**: classifier reads the receipt from the card's comments on disk (fresh, `to.lane` = current lane), falls back to stamp age; a receipt itself prints no line.
- **Rejected**: asking the owner about the `moved:` shape or Shortcuts. The guide and `.schema/common.json` answer both: one shape, written for app and Shortcuts moves.
- **Accepted limitation**: a bare `mv` writes no receipt, so the stamp-age rule stays.
- **Evidence**: read-only inspection of `events.md`, `classify-event.sh`, `tests/smoke.sh` (dispatch block), README § Sizes. Nothing was run.
