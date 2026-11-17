---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:38:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T11:38:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
Done in d3ad138. The lanes tables have an `icon` column between `collapsed` and `body`, and only the pipeline table fills it. `found-board.sh` writes `icon:` after `order:`. `heal-descriptors.py` and smoke now read the body from column 6.

**Evidence**: `bash tests/smoke.sh` → "smoke: 80 passed". The new case 6 founds a pipeline board: all 8 lanes carry an icon, Issues is `{glyph: exclamationmark.triangle, color: carnation}` and Ideas is `{glyph: lightbulb}`. The design-loop lanes carry no icon. Every founded board validates. The stamp gate passed only on another session's uncommitted v84 bump in `CLAUDE.md`. Cases 1–78 passed without it.

This board's lanes got the same set in 97f1aea.
