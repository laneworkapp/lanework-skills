---
schema: 1
kind: card
title: "discovery: DRY, telegraphic restructure"
order: 3072
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-27T20:54:30Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T20:54:30Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Cut the `discovery` skill's verbosity without losing clarity. Owner's rulings in session: telegraphic style, fragments allowed; applies to all agent-facing text, while board text the owner reads in the app stays prose; no duplication, so `SKILL.md` is a hub referencing one file per topic, with repeated topics linked rather than restated.

## Done when

- `SKILL.md` is a hub: flow, resume, scripts, and a topics table.
- Each topic lives once: `references/` corners, board, rounds, records, conduct. Literal shapes live in `templates/`.
- The founding script renders the board and lanes from `templates/`, with no copy of their text.
- Shared helpers live in `scripts/lib.sh`.
- `lanework-boards` points at `discovery` instead of restating it.
