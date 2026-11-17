---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:01:17Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:01:17Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Code-complete at `f50e26f` on `guide-v114-2c29a34f`, rebased on `origin/main` (`98443ce`) and pushed. Gate not yet run: waiting on the slot.**

**Decided**: the new smoke cases build their own throwaway boards and never call the board's validator or heal, so they pass under the committed v1/v2 `.schema/` and under the app's v4/v5 alike.
**Decided**: the heal case's root `component: {text: Sync}` line is dropped from card 5. Kept, it would print `DEPRECATED` under the v1 validator. The root-`component:` check moved to the new V114 board.
**Decided**: in the `appside` case `AL` moves to 2026-11-13, so A's edits stay later than the new app writes (2026-11-12). `AE` stays: `card-title-edit` is unchanged.
**Decided**: the merge check calls `board_singles` directly, not through a two-clone merge: that is the one seam the change touches.
**Decided**: writes.md gates `stale-label`/`single-kind` on the owner's ask at the `--apply` step. Neither heal can apply some rules and not others.
**Rejected**: restating the v105 floor in `ask.md`. It lives in `writing.md` § The ask alone.
**Evidence**: the four new cases, `appside`, and the discovery/plan excerpts carrying list-form `waiting` all pass when run alone. `check-refs`: 248 refs, 0 missing. `check-sizes`: 62 rows, 0 wrong. The `appside` boards also pass the app's v4 validator: 0 failures over 29-31 documents, 1 WARN (the fixture's dangling `in-reply-to`).
