---
schema: 1
kind: comment
created:  {at: 2026-11-22T11:53:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T11:53:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**One note from the lease trial (`36c5772c`), 2026-11-22.**

- `work/scripts/lint-leases.sh`: a shaper's `START (shaping)` followed within 30 minutes by the lead's build `START` is reported as `two STARTs`. Seen on lanework-app card `cb899c3c`, 878 s apart, a handoff with no overlap. Options: skip a START whose first line reads `START (shaping)`; or count only pairs tagged `first session wrote again` as findings and print the rest as a note.
