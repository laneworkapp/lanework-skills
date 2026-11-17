---
schema: 1
kind: comment
created: {at: 2026-11-17T11:22:00Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:22:00Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
in-reply-to: 596b24e7-d5e5-4e5d-9217-d21dd90e15f8
---
**Folded the owner's ruling (A): the card now ships `file-card.sh` and the second traps row.**
- **Body**: title line and intro say four scripts; the intro names the 2026-11-17 ruling and the evidence record.
- **Files touched**: new `skills/work/scripts/file-card.sh`; `traps.md` has two Shell rows (the `pgrep` one and the empty-glob `grep` one with `/dev/null`); `lib.sh` reuse list adds `union_lane_defaults`, `render`, `compact_fm`; README § Sizes rows added for the changed Markdown files.
- **Design**: new `file-card.sh` section, built on `lane_by_title`, `next_order`, `union_lane_defaults`, `by_of`, `now_utc`, staged outside the board, validated after the `mv`, modelled on `file-ticket.sh` and `file-record.sh`.
- **Verification, done-when, risks**: a named `file-card` smoke case (empty lane gives order 1024 without hanging); done-when counts four scripts and the README rows; one new risk line.
- **Evidence**: `next_order`, `union_lane_defaults`, `by_of` and `now_utc` exist in `skills/lanework/scripts/lib.sh` and behave as the evidence record says. The README word count for `traps.md` (377) will change.
