---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:34:48Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T10:34:48Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Verified: full `tests/smoke.sh` green on branch `type-kind-cube` (head 6934549, rebased on origin/main f9ba99c). Last line: `smoke: 118 passed`.**

- **Change**: `skills/lanework/templates/label-kinds.md` type row now `icon: {glyph: cube}`; `tests/smoke.sh` card fixture (old line 852) moved to `cube`; new assertion after the `--labels` subset test. Lines 52, 809, 901 untouched (board icons).
- **New assertion** (ok line): `found-board.sh --labels type stamps icon: {glyph: cube} on the type kind, leaves its five values' glyphs alone, and the board validates`.
- **Sizes**: `tests/check-sizes.sh` reports `62 rows, 0 wrong`; README not touched.
- **SF Symbols**: `cube` is listed in the macOS CoreGlyphs data (`symbol_order.plist`, `name_availability.plist`: 2019). Not checked by eye in the SF Symbols app.
- **Raw output**: attached (smoke-run.txt).
