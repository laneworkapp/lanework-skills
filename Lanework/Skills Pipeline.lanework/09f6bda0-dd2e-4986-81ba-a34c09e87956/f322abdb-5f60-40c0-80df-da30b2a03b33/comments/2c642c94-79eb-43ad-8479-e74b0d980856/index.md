---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:34:10Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Reviewer NOTEs 1 and 2 folded in; rebased on origin/main 2dc7b75 as `7ff1c5c`.**

- **NOTE 2**: the "already has an entry of K" bullet now says the kind matches case-insensitively on `kind.type`.
- **NOTE 1**: the stamping bullet now says stamp from `config.labels` if K is defined there, else copy the shape from the board card the value came from.
- **README § Sizes**: conflict with the guide branch resolved; sweep.md 730 words, work total and summary 6,698.
- **Scoped checks**: `check-sizes: 62 rows, 0 wrong`; `check-refs: 248 references, 0 missing`; rule text appears once under `skills/`. Full gate not rerun, awaiting the slot.
