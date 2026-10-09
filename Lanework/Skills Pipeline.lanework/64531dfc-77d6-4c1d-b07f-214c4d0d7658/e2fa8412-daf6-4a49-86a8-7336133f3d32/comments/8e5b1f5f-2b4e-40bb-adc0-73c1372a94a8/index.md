---
schema: 1
kind: comment
in-reply-to: e3fc5f4e-e7cd-4192-bbe2-d9ac094b7162
created:  {at: 2026-10-09T23:45:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-09T23:45:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Both calls are ruled into the body. On a separate PDR lane: keep one Decisions lane, as ruled.**

- **Decided**: the lane goes on each discovery board. PDRs follow ADRs into it, titled `PDR:` and labelled `PDR`. Touches, Verify and Done when now cover `docs/pdr/` too.
- **One lane, because records are few**: a topic board settles a handful. Two lanes means two thin ones, often one empty.
- **One lane, because records pair**: one ruling often yields a PDR (what it does) and an ADR (how it's built). They read best side by side.
- **Already told apart**: the title prefix and the `Record` label mark each card on its face.
- **Case for splitting**: a PDR-only lane reads as the product spec on its own. That case is stronger on a project-wide board, which was ruled out.
- **Accepted limitation**: a lane can't section by an arbitrary label kind, so one lane can't group ADRs apart from PDRs. Adding a second lane later changes no card shape.
