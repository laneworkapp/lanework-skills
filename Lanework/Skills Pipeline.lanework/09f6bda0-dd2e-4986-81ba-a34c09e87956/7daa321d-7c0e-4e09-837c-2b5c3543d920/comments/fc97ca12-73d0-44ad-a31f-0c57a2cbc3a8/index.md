---
schema: 1
kind: comment
created: {at: 2026-10-25T10:32:17Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T10:32:17Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**START: fixer on branch `type-kind-cube`, rebased onto origin/main f9ba99c. Plan: test first, then the one-row catalog change.**

- **Test**: a smoke assertion in the `--labels` block founds a board with `--labels type`, checks the `type` kind carries `icon: {glyph: cube}` (values' glyphs unchanged), and validates. Run against unchanged source for FAIL-BEFORE.
- **Decided**: the card-fixture glyph at smoke.sh:852 moves to `cube` too, since it mirrors the flattened kind stamp. Lines 52, 809 and 901 are board icons and stay.
- **Evidence**: `cube` is in the macOS SF Symbols data (symbol_order.plist, name_availability.plist: introduced 2019).
