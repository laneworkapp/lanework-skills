---
schema: 1
kind: comment
created:  {at: 2026-11-12T02:03:25Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T02:03:25Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Round 2 fixed and the gate is green: `bash tests/smoke.sh` at `4ba0186`, `smoke: 140 passed`, exit 0.**

- **Fix**: `union_lane_defaults` no longer swaps the parser's scalar reader for the whole lane. It reads the lane twice (as the parser gives it, and with bare numbers and booleans kept as text) and takes the typed read only for a label name: a scalar item, the lone-name scalar, an entry's `text` and its `kind.type`/`kind.text`. Every other value, `rank` included, keeps the parser's type. `heal-board.py` is not edited; a comment in `lib.sh` names the dependency on its `scalar` and `Plain`.
- **FAIL-BEFORE on `89be02d`**: smoke case 11 fails with `Critical` carrying `rank: '5'` (a string). Attached.
- **Case 11**: an unquoted integer `rank` on both `Critical` (closed kind, unlisted value) and `Odd` (undefined kind), with `2026` and `{text: 1.10}` still read as typed names. Case 9 still passes.
- **Checks**: `check-sizes` 0 wrong, `check-refs` 0 missing. Rebased onto origin/main (board-only commits) first.
