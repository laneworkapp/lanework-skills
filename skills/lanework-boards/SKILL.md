---
name: lanework-boards
description: "Lanework board fundamentals: what a board is (a `<Name>.lanework` folder of plain dirs + Markdown that the Lanework macOS app renders live; the files ARE the board, no API), the authority chain to read before any write, where boards live, reading a board in one pass, the write rules every board shares, the default lane sets (pipeline, design loop, datapoint), and founding a new board. The base the pitlane, pitwall and discovery skills build on. Use when the user wants a new board ('create/found/start a board', 'set up a lanework board for X', 'a board for tracking X'), or asks what a Lanework board is or how boards work. Not for sweeping or working a board (pitlane) or watching one live (pitwall)."
---

# Lanework boards

A board is a folder of plain dirs + Markdown that the Lanework app renders live. Edit the files: that is the whole interface.

## Topics

| topic | file |
|---|---|
| format: depth, uuids, `index.md`, app-owned files | `references/format.md` |
| authority chain: read before any write | `references/authority.md` |
| where boards live | `references/finding.md` |
| reading order, one-pass read, threads | `references/reading.md` |
| write rules: stamps, atomic, paths, placing, git | `references/writes.md` |
| founding a new board | `references/founding.md` |
| default lane sets and who moves cards | `references/board-kinds.md` |
| index and lane templates | `templates/` |

## Scripts

| script | does |
|---|---|
| `scripts/read-board.sh <board>` | prints lanes and cards in reading order |
| `scripts/found-board.sh <board> --index F --lanes F` | founds a board from templates |
| `scripts/lib.sh` | shared helpers, sourced by every skill's scripts |

## Built on this

**pitlane**: sweeping and working a board, writing cards and comments. **pitwall**: a live watch. **discovery**: a question-by-question examination on its own board kind.

## Versioning

Written against `lanework-agent-guide v67` and `lanework-schema v1`. Checking versions: `references/authority.md`.
