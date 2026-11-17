---
schema: 1
kind: comment
created:  {at: 2026-11-17T21:35:02Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**FAIL-BEFORE, then built: smoke cases 1 to 8 against `18ab58f`, then green on `478a726`.**

- **Before** (cases run against the unchanged `skills/` at `18ab58f`, lease fixtures hand-written on a throwaway board): `NOT OK` for the full-board line check, case 1 (leased card printed `arm`, no `held`), case 2 (lapsed lease printed `arm`, no `stale`), case 3 (START-only card printed `stale ... 120m`, no `arm`), case 4 (an until 50 minutes ahead with a fresh START printed no `arm`), case 6 (no `held` after `comment`), the lease.sh-missing case and the watch prose case. Cases 5 (Done) and 7 (byte-identical) passed on the old script: the old pass never swept Done and wrote nothing, so they are regression guards, not fail-before.
- **After**: `tests/smoke.sh` last line `smoke: 238 passed`. Main was `smoke: 229 passed`: 229 - 2 (the old arm-pass cases) + 10 (full-board, cases 1 to 7, command-line titles and non-board, lease.sh missing) + 1 (watch prose) = 238.
- **Decided** (body left open): when `lease.sh list` fails or is missing, `arm-pass.sh` prints `comment` lines only, a note on stderr, and exits 1. Why: an `arm` printed with no lease data could double-dispatch a card another session holds; `comment` lines read no lease, so they stay.
- **Commit**: `478a726` on `watch-lease`, pushed. `tests/check-sizes.sh` 0 wrong; `tests/check-refs.sh` 0 missing.
