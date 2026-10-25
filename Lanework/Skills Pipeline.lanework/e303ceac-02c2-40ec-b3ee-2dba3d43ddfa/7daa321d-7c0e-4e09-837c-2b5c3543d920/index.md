---
schema: 1
kind: card
title: "Label catalog: a glyph that says \"type\" for the type kind"
order: 48128
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created: {at: 2026-10-13T15:16:10Z}
modified: {at: 2026-10-25T10:42:41Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
The `type` kind in the label catalog draws as `square.grid.2x2`, a generic grid that says nothing about kinds of work. Its five values already have glyphs of their own (Bug `ladybug`, Feature `sparkles`, Chore `wrench`, Docs `doc.text`, Spike `magnifyingglass`). Only the kind's own glyph is in question.

## Proposal

- **Decided** (owner, 2026-10-13): the kind's glyph becomes `cube`, one solid form for "what it's made of".
- **Considered**: `square.on.circle` (two shapes, kinds of thing) and `rectangle.3.group` (grouped tiles).
- **Not offered**: `tag` (the built-in `text` kind uses it), `shippingbox` (`release`), `puzzlepiece` (`component`).

## Touches

`skills/lanework/templates/label-kinds.md` (the `type` row: `icon: {glyph: …}` on the kind), `README.md` § Sizes only if the row's word count moves (`tests/check-sizes.sh` names it).

## Verify

`tests/smoke.sh` passes. A board founded with `--labels type` stamps the new glyph on its `type` kind, and validates. The glyph name is checked in SF Symbols on macOS 26.

## Done when

The catalog's `type` kind carries `icon: {glyph: cube}`, and smoke passes.

## Out of scope

Existing boards: kinds are stamped whole on each label entry, so boards already founded keep `square.grid.2x2` until their labels are re-stamped.
