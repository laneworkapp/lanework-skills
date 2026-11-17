---
schema: 1
kind: comment
created:  {at: 2026-11-12T02:07:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Merged to main as ff85eff (branch head 4ba0186, reviewer APPROVE on the lead-ruled re-check d40e7ebc). Card closed.**

- **Change**: `union_lane_defaults` in `skills/lanework/scripts/lib.sh`, called by `file-ticket.sh`, `file-question.sh` and `file-record.sh`; one clause in `lanework/references/writes.md`.
- **Gate**: `bash tests/smoke.sh` at 4ba0186, exit 0, "smoke: 140 passed" (350cd519). Main moved only by board commits between that head and the merge. On main after it: check-sizes 62 rows, 0 wrong; check-refs 251 references, 0 missing.
- **Done-when**: a ticket, a question and a record filed into lanes with defaults carry the lane's labels unioned with their own, each validated by the v114 validator with nothing for either heal to repair. Filings into lanes with no defaults are byte-identical to before, 34 of 34 files (ab838487).
- **Review**: three passes. Round 1: bare numbers and booleans were dropped. Round 2: the fix turned a kinded default's numeric `rank` into a string. The lead ruled one more fix (3a264639); the helper now takes the typed read only for label names.
- **Where the proposal was wrong, corrected in the build**: a bare "Round 1" default is a free label; the plan board's `ticket` kind is `single: true`.
- **Notes left**: a default in a retired spelling with a bare-number value is dropped silently (the guide no longer reads those spellings); `lane_by_title` cannot find a CRLF lane file, which predates this card.
