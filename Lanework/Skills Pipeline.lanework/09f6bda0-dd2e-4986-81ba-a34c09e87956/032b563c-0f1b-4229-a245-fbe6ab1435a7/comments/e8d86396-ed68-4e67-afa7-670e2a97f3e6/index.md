---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:35:50Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:35:50Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Rebased onto origin/main `2dc7b75` (guide v114) as `6b1bf92`; the five cases pass scoped on the real boards, the strip is gone.**

- **Changed**: `nothing_to_heal` validates and heals the real board with the lanes' `card-defaults` lines in; the v4 validator and heal v5 object to nothing the helper writes. `setdef` now writes the lane key with the heal's own `emit_key`, because the heal compacts a hand-written line over 120 characters (my fixture, not the helper). `labels_of` asserts each filed card with `fm_parses`.
- **Checked**: every name `lib.sh` imports from `heal-board.py` still exists (`Doc`, `ParseError`, `definitions_of`, `config_labels`, `normalize_entry`, `entry_of`, `flattened`, `numeric_rank`, `emit_key`, `canon`, `is_text`).
- **Evidence**: scoped runner 8 `ok` including the five new, `tests/check-sizes.sh` 0 wrong (README `writes.md` 1,037, lanework total 4,232), `tests/check-refs.sh` 0 missing. Full gate not run.
