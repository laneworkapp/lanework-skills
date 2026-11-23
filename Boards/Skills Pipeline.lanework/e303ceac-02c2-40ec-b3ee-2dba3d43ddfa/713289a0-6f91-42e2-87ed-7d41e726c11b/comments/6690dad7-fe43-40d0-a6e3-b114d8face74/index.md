---
schema: 1
kind: comment
created:  {at: 2026-11-23T04:03:34Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T04:03:34Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: the three slices are built, reviewed and on main.**

- **Slice 1, settle-question:** a `Recap:` click is refused in every form (BOM, CRLF, 200 KB); `--record` with `waiting` cleared answers the newest ask.
- **Slice 2, hardening:** the lease timer outlives an unwritable memory folder and no longer brings back a released memory file (window narrowed, not closed: closing it needs a lock); `push_bounded` holds a signal across the fork and says why it gave up; an expired label hold exits 1; a failed founding removes only what the run created.
- **Slice 3, consistency:** seven usage lines; exit 2 for an unreadable `--body`, `--index`, `--lanes` in `file-card.sh` and `found-board.sh`; four headers; quoted stamp names read whole; the CDPATH case; the smoke guard and `bq()`.
- **Changed from the proposal:** the lint skip keyed on `START (shaping)`, a form no skill prescribes. `writing.md` § START now names `**START: shaping: <plan>**` and the lint skips a START whose plan opens with `shaping`. Accepted: two shaping STARTs on one card are no longer flagged, nor a plan that happens to open with that word.
- **Left out, on record:** `post-ask.sh`, `post-comment.sh`, `move-card.sh` still exit 1 for an unreadable file; a directory given as `--body` exits 1; the board `index.md` move before the lane loop in `found-board.sh` is unguarded.
- **Evidence:** each slice reviewed separately, approved after one fix pass; full smoke on the combined tree: 408 passed. Four earlier full runs failed on test faults (shared variable names across sections, one test editing a claim under a live timer), all fixed in `tests/smoke.sh`.
- **CHANGELOG:** Several scripts now report bad arguments and unreadable files consistently, and lease renewal keeps working through a temporary file-permission problem.
