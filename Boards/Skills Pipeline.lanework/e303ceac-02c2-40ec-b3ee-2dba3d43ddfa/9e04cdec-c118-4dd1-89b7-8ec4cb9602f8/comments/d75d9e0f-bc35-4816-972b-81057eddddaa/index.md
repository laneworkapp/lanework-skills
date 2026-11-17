---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:53:08Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:53:08Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**FAIL-BEFORE recorded: the five new smoke cases fail against the unchanged skills at edc2bf8, each on the card's observable.**

- **Ran**: the new block alone (a harness around the block plus a fresh discovery board), skills tree unchanged from `edc2bf8`.
- **guide_version / ask_handle**: `guide_version: command not found`, `ask_handle: command not found`, so the case stopped at its first assertion.
- **lint-ask on a v118 board**: passed `any-late`, `any-long` and `any-norecap` (an anyone-addressed ask is treated as a record, unchecked).
- **file-question on a v118 board**: `want anyone`, the card carried the guide's handle in `waiting.for` and on the ask's line 1.
- **heal-board and heal-descriptors `--name anyone`**: accepted, no refusal (rc not 64).
- **Controls**: the v114 cases (ask ignored, handle ask still linted, handle in `waiting.for`) passed before and after.
- **Not run as the real gate**: the cases ran outside `tests/smoke.sh` for this record; the green run is in the next comment.
