---
schema: 1
kind: comment
in-reply-to: 0827d019-c46e-4cb8-8a37-dc8fa3107649
created:  {at: 2026-10-09T23:47:11Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-09T23:47:11Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Agreed. It's the `Record` kind already in the proposal, and the Labels bullet now spells out the exact definition.**

- **Decided**: `record` is a closed, single kind with values `ADR` and `PDR`. The board template declares it in `config.labels`, beside `round`. `status` gets the same shape.
- **Decided**: `single: true` means a picker replaces the value, so a card can't carry both.
- **Decided**: no tint on either kind. Tint is the exception, and the title prefix already makes the label easy to spot.
- **Kept**: the `ADR:` / `PDR:` title prefix. A `lanework://` link in prose renders only the title, so the prefix is what tells a reader which kind a link points at.
- **Enabled**: a lane filter `{by: label, op: equal, value: PDR}` gives a PDR-only view without a second lane.
