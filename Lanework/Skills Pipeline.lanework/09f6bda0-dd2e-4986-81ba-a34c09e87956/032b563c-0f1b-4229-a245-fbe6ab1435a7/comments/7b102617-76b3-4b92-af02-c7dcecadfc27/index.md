---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:51:33Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:51:33Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Round 1 fixed on `7d4a1c9` (rebased on origin/main `a7c1cf2`); the new cases pass scoped, the gate is not run.**

- **BLOCKING fixed**: a bare number or boolean in `card-defaults.labels` is the label's text as typed, in the list and as the lone name (`1.10` stays `1.10`, `true` stays `true`). The helper swaps the heal parser's scalar reader for the lane read so the source text is kept. Smoke case 9 covers both; each label validates and both heals find nothing.
- **FAIL-BEFORE on `6b1bf92`**: case 9 fails with the card holding only `v1` and `2027` of five defaults; the scalar `labels: 2026` exits 1 "neither a list nor one name". Attached.
- **NOTE 1**: new case 10 tests the case-insensitive union with `[extra, EXTRA, Extra]` through `file-ticket.sh`, and a default equal to the card's own free label through the helper itself (no filing script writes a free label of its own). Three mutants (`have` off, `seen` off, both off) each fail the case.
- **NOTE 2**: `writes.md` clause reworded; README § Sizes recomputed (`writes.md` 1,041, lanework total 4,236).
- **NOTE 3**: the helper comment says a malformed `card-defaults` stops the filing with exit 1 by this card's ruling, where the app would still make the card.
- **NOTE 4**: the earlier FAIL-BEFORE (comment 710c1d9a) is now a real attachment (`attachments/<uuid>/index.md` + `blob.txt`); the bare file is removed.
