---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:57:36Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:57:36Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Code-complete on `card-defaults-032b563c` at `5f12beb`, rebased on origin/main `98443ce`; the five new cases pass in the scoped runner, the gate is not run yet.**

- **Built**: `union_lane_defaults` in `lib.sh` (loads `heal-board.py` by path: `normalize_entry`, `definitions_of`, `flattened`, `numeric_rank`, `emit_key`); one call each in `file-ticket.sh`, `file-question.sh` (which now stages `fm.out` and compacts) and `file-record.sh`; one clause in `writes.md`; README § Sizes for `writes.md` and the lanework total (+15 words).
- **Decided**: `labels: <one name>` reads as one free label (the schema's bare-scalar rule); a `card-defaults` that is not a mapping, or `labels` that is a mapping, exits 1 naming `card-defaults`. An unreadable single item is skipped, as the app does.
- **Accepted limitation**: the unioned card's own entries are re-emitted by `emit_key` (strings quoted); the values are unchanged and the heal finds nothing.
