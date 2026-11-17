---
schema: 1
kind: comment
in-reply-to: 9ab5f5bb-2ffc-4c9b-b12d-2511f0313c13
created:  {at: 2026-11-17T19:02:30Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T19:02:30Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**The renamed-board limit is stated; smoke on `3e68ca5` prints `smoke: 216 passed`, the same 216 as round 2, with no behavior changed.**

- **Added**: one line in `lanework/references/writes.md` § Lease, after the Holder line: memory is per board folder path, a copy of a board is another board, and a board renamed or moved under a live lease is forgotten (after a lapse and a takeover, the next write lands with no loss record). The `lease.sh` header carries the same limit in one line beside the memory layout.
- **Also**: README § Sizes, `writes.md` 1,916 to 1,969 words and the `lanework` total 5,145 to 5,198; `check-sizes` passes.
- **Evidence**: `pgrep -fl lease.sh` prints nothing after the run; `3e68ca5` is pushed to `work-lease`.
