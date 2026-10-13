---
schema: 1
kind: card
title: "Label catalog: a glyph that says \"type\" for the type kind"
order: 2048
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
waiting: {for: rzen, since: 2026-10-13T15:17:14Z, comment: bf711988-e069-40ee-bdba-b02712d08c67}
created: {at: 2026-10-13T15:16:10Z}
modified: {at: 2026-10-13T15:17:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The `type` kind in the label catalog draws as `square.grid.2x2`, a generic grid that says nothing about kinds of work. Its five values already have glyphs of their own (Bug `ladybug`, Feature `sparkles`, Chore `wrench`, Docs `doc.text`, Spike `magnifyingglass`). Only the kind's own glyph is in question.

## Proposal

- ~~**Open call**~~, **open**: which glyph the kind gets. **Recommendation: A, `square.on.circle`.**
- **A, `square.on.circle`** (recommended): two shapes, so "different kinds of thing". It reads at chip size and doesn't clash with any other catalog kind.
- **B, `rectangle.3.group`**: three grouped tiles, so "sorted into groups". Close to the current grid in spirit, but less abstract.
- **C, `cube`**: one solid form, so "what it's made of". Distinct, but reads more like a build artifact or release.
- **Not offered**: `tag` (the built-in `text` kind uses it), `shippingbox` (`release`), `puzzlepiece` (`component`).

## Touches

`skills/lanework/templates/label-kinds.md` (the `type` row: `icon: {glyph: …}` on the kind), `README.md` § Sizes only if the row's word count moves (`tests/check-sizes.sh` names it).

## Verify

`tests/smoke.sh` passes. A board founded with `--labels type` stamps the new glyph on its `type` kind, and validates. The glyph name is checked in SF Symbols on macOS 26.

## Done when

The catalog's `type` kind carries the chosen glyph, and smoke passes.

## Out of scope

Existing boards: kinds are stamped whole on each label entry, so boards already founded keep `square.grid.2x2` until their labels are re-stamped.
