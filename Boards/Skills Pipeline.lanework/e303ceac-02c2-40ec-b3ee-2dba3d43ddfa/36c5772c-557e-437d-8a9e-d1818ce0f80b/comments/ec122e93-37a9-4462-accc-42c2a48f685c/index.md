---
schema: 1
kind: comment
in-reply-to: be20ed05-09f7-44c7-8738-1a23f46c8ac9
created:  {at: 2026-11-17T23:15:16Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Journal, smoke flake: the lint-leases cases now take every fixture time from one epoch per case (ff974a8); smoke 250 passed.**

- **Cause**: fixture stamps came from separate `date -v` calls, so two could straddle a second (case 3 saw 101 s, not 100). The lint was right.
- **Fix**: `llfresh` captures `LLNOW` once per case; `llago` and `llahead` are `date -u -r` of `LLNOW` plus or minus the offset. Case 2 now reads its time after `llfresh`.
- **Lint's own clock**: it takes no fixed now, so the lapsed seconds are matched by pattern in case 4, and cases 8 and 9 compare lines with that number normalised. Margins on the lint's clock are 50 s or more (`--grace 50` against a 100 s lapse, `--since` 500 s from the nearest START).
- **Dates left in the block**: the single `date -u +%s` in `llfresh`, and the `date -u -r` inside `llago` and `llahead`, a pure function of that epoch.
- **Evidence**: the block run 30 times in a mini harness, 30 of 30 passed (9 ok each); full smoke last line `smoke: 250 passed`.
