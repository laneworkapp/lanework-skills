---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:04:59Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:04:59Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**FAIL-BEFORE: the new smoke cases fail on the unchanged tree, and each of the 14 defects fails on Pitwall's own script and passes on the new one.**

- **Smoke on the merge-base** (`2023143`, cases added, scripts absent): `tests/smoke.sh` stopped after `ok 149` with `file-card printed` (exit 1). The harness is new, so this run shows the cases are wired, not each observable.
- **Per-defect control**: a scratch script ran each defect's observable against Pitwall's `move.sh`, `post.sh`, `succ-commit.sh` and the empty-lane glob (board and lock paths made parameters, logic as sent), then against the new scripts. 14 of 14 FAIL on Pitwall's, 14 of 14 PASS on the new.
- **Defects**: D1 hardcoded `by`; D2 no `order`; D3 `git mv` stages; D4 first prefix match taken; D5 no lint; D6 ask in the record's second; D7 no `waiting`; D8 a bare prefix accepted; D9 trailer always; D10 push always; D11 a folder drags in `.DS_Store`; D12 the ff-only stop names no file; D13 a dead holder's lock never reclaimed; D14 the empty-lane glob hangs.
- **Logs** (scratchpad, not attached): `fail-before.log`, `defects.log`, `defects.sh`, `pitwall/`.
