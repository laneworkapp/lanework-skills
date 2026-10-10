---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:58:34Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:58:34Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Review notes 1, 2, 3 and 5 fixed in one commit; gate green.**

- **Fixed**: fence closes only on the opener's character at its length or longer (fixtures: four backticks around three, tildes inside backticks); a quote behind a list marker counts as a quote; a bullet-only line is a bullet, number or task box (fixtures: `1. S`, `- [ ] S`). Note 4 left alone.
- **Decided**: gate key now reads "agents move cards in only, and out only in discovery Asked once the ruling is in the body". `sweep.md:27` ("move only as the `gate` key allows") reads correctly against it, and nothing contradicts `board-kinds.md:12`.
- **Mutation check** (script variants under $TMPDIR): toggle-only fence fails nested and tilde; no list-marker strip fails list-quote; old bullet set fails numbered and task. The real script passes all five.
- **Gate**: `env -u CLAUDE_MODEL bash tests/smoke.sh` ends `smoke: 81 passed`, rc 0; check-refs 0 missing; check-sizes `48 rows, 0 wrong` (board-kinds 1,078, lanework total 4,008).
