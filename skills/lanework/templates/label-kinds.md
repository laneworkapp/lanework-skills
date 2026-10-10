# Label kinds

Read by `scripts/found-board.sh --labels` and `scripts/heal-board.py`. One row per kind: the entry is a one-line flow mapping for the board's `config.labels`, in the guide's key order. `priority` and `component` are the guide's suggested definitions, verbatim. Closed kinds list `values`, each with its `rank`; open kinds have none. No `|` in an entry.

| type | entry |
|---|---|
| priority | {type: priority, text: Priority, icon: {glyph: flag}, single: true, values: [{text: Urgent, rank: 0, color: "#C8283C", icon: {glyph: exclamationmark.2}}, {text: High, rank: 1, color: "#E07A1F", icon: {glyph: exclamationmark}}, {text: Medium, rank: 2}, {text: Low, rank: 3, icon: {glyph: arrow.down}}]} |
| component | {type: component, text: Component, color: aluminum, icon: {glyph: puzzlepiece}, single: true} |
| type | {type: type, text: Type, icon: {glyph: square.grid.2x2}, single: true, values: [{text: Bug, rank: 1, icon: {glyph: ladybug}}, {text: Feature, rank: 2, icon: {glyph: sparkles}}, {text: Chore, rank: 3, icon: {glyph: wrench}}, {text: Docs, rank: 4, icon: {glyph: doc.text}}, {text: Spike, rank: 5, icon: {glyph: magnifyingglass}}]} |
| size | {type: size, text: Size, icon: {glyph: ruler}, single: true, values: [{text: XS, rank: 0}, {text: S, rank: 1}, {text: M, rank: 2}, {text: L, rank: 3}, {text: XL, rank: 4}]} |
| platform | {type: platform, text: Platform, icon: {glyph: laptopcomputer.and.iphone}} |
| round | {type: round, text: Round, single: true} |
| release | {type: release, text: Release, icon: {glyph: shippingbox}, single: true} |
| epic | {type: epic, text: Epic, icon: {glyph: mountain.2}, single: true} |
