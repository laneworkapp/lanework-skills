---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:32:46Z, by: {name: shaper, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:32:46Z, by: {name: shaper, kind: agent, model: sonnet}}
---
**Shaped: all three gaps are real at HEAD, and no owner-only choice remains.**

- **Evidence**: `board-kinds.md:5` "agents move cards in only" against `:72` "Only the agent moves a card out" (also `discovery/templates/lanes.md:9`, `heal-descriptors.py:145`). `heal-descriptors.py` ~415 matches `\s?`+sentence over the whole body with `count=1`. `sweep.md:27` and `:28` both list Ideas.
- **Decided**: reword the key, not the Asked row. The row is lane-body text already on users' boards, so rewording it would force an `OLD_BODIES` entry and a `replace-body` on every healed discovery board; the key only documents existing behaviour, so owner-facing semantics do not change.
- **Decided**: drop-stale goes per line, skipping fences and quotes, dropping a line left empty or bare-bulleted. Rejected: one anchored regex, which cannot see fence state.
- **Decided**: Ideas stays in Holding only, since `board-kinds.md:16` makes it `holding`; the gate row follows the `gate` key.
- **Order**: build after c8cf1d23, which edits `read_templates` and smoke's lane fixtures.
