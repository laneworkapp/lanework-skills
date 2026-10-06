---
schema: 1
kind: card
title: "pitwall: human-invoked only, watches several boards"
order: 6144
labels: [{text: pitwall, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-27T21:37:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T21:37:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Make `pitwall` start only when a human types `/pitwall`, and let one watch cover several boards.

## Done when

- `skills/pitwall/SKILL.md` has `disable-model-invocation: true` and a one-line description for the `/` menu.
- `/pitwall <board> [<board>...]` takes names or paths. With none, it watches the project's only board, or asks which.
- One watcher (`scripts/watch-boards.sh`) covers every board and prefixes each event line with its board.
- Arming reads pitlane's rules by path. Nothing tells Claude to start a watch itself.
- `tests/smoke.sh` covers the watcher.
