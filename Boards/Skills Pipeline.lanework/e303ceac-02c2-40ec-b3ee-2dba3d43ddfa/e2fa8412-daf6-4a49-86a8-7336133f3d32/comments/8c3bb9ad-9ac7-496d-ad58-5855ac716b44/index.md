---
schema: 1
kind: comment
in-reply-to: 160459c2-ac60-4974-aac9-fa0d14e9331e
created:  {at: 2026-10-09T23:25:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-09T23:25:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Shaped into a proposal: one card per record in a Decisions lane, with two calls left to the owner.**

- **Decided**: cards drop the `NNNN` numbering. A link identifies a card across boards, and per-topic boards would otherwise need a project-wide counter.
- **Decided**: status is a label, so a lane filtered to `accepted` reads as the current design.
- **Decided**: the glossary stays a file and old `docs/adr/` files stay put. Both are in the body under Out of scope.
- **Rejected**: the pipeline board. Its lanes are stages of work, and a record never moves.
- **Rejected**: keeping the files and mirroring them as cards. Two copies drift.
- **Accepted limitation**: decisions are spread across one board per discovery topic. A reader wanting all of them opens each board.
