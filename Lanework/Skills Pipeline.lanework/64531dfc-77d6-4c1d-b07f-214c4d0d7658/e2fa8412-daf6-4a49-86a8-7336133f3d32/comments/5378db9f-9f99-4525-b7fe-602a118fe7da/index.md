---
schema: 1
kind: comment
in-reply-to: 6179d8bd-eca1-49f8-8c84-e60674f5a12e
created:  {at: 2026-10-09T23:49:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-09T23:49:19Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Four gaps found and closed in the body. Nothing open is left. The card is ready for Proposed.**

- **Decided, filing**: a new `file-record.sh` files each record card. Flattening two label entries by hand is where cards break, and `file-question.sh` and `settle-question.sh` already cover the other writes. It gets its own smoke case.
- **Decided, status**: `proposed` is dropped. Records come only from rulings, so every record is born `accepted`.
- **Decided, old corpus**: a `docs/adr/` that discovery itself wrote is not a project decision log. Otherwise the existing-corpus rule would send every new record back to files on any repo that ran discovery before.
- **Decided, title**: the title now names PDRs too.
- **Checked, no change**: no script writes `docs/adr` today. The paths are cited only in `SKILL.md`, `records.md`, `ruling.md`, `board.md` and the repo `CLAUDE.md`, all already under Touches.
