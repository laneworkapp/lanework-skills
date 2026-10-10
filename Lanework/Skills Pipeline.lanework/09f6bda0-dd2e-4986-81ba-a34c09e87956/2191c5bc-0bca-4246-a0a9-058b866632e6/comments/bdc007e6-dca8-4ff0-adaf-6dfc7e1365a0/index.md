---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:56:15Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:56:15Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Round 1b built and green: commit 1e8a8e0 on `label-kinds`. `tests/smoke.sh` prints `smoke: 73 passed`, no red line.**

- **Changed, round**: catalog row `{type: round, text: Round, single: true}` (no icon). `found-board.sh` fills a second slot `{{label_entries}}` ("row, " per entry, empty without `--labels`). `discovery/templates/board.md` uses it, `found-discovery-board.sh` passes `--labels round`. A founded discovery board's config is byte-identical to the pre-change golden (`tests/fixtures/founded-discovery-index.md`) except round gains `single: true`; it validates.
- **Changed, heal**: the hard failure is gone. `EMBEDDED_SUGGESTED` holds the literals; `SUGGESTED` reads the catalog when `../templates/label-kinds.md` exists, else the embedded copy. Smoke asserts the literals equal the catalog rows, and runs a copy of the script alone (no catalog beside it) that heals a card's root `priority` into a definition.
- **Changed, prose**: board-kinds.md discovery default names round; founding.md and README list eight kinds; Sizes rows refreshed (lanework 342 / 3,746).
