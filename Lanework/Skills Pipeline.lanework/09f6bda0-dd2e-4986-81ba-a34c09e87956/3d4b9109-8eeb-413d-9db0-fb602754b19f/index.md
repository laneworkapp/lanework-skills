---
schema: 1
kind: card
title: "Smoke is red: the board's guide moved to v101, the skills are stamped v93"
order: 2048
labels: [{text: repo, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T10:44:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T10:44:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The Lanework app rewrote this board's guide to `lanework-agent-guide v101`, eight versions past the skills' `v93` stamp. Smoke's stamp gate now fails on main, and that blocks the 0.7.0 release.

## What v101 changed (board `CLAUDE.md` diff, committed in `9a12b5d`)

To be filled from the diff by the fixer. Known so far:

- A lane's `card-defaults.labels` may hold full kinded entries, re-stamped at birth, and a card's own value of a `single` kind wins.
- Board Settings now writes `due-soon`, `labels` kinds, `thumb-sizes` and `logging`. "No control in the app" is gone.
- The effective vocabulary is `config.labels` plus the built-in `text` kind.
- The board's heal (`.schema/bin/lanework-heal.py`, `HEAL.md`) moved too.
- `.gitignore` seed v5 drops `.tracker.nosync/`.

## Fix

Read every file under `skills/` against the v93→v101 guide diff and the board heal diff. Fix the drift, mirror any heal rule the skill's own `lanework/scripts/heal-board.py` should match, then bump the stamp to `v101` in the repo `CLAUDE.md`.

## Verify

`tests/smoke.sh` passes on a checkout whose board guide is v101, with the stamp case reading v101. `tests/check-sizes.sh` reports 0 wrong. Prose read through against guide v101.

## Done when

Every skill reads true against guide v101, smoke passes with the stamp case reading v101, and the release gate no longer blocks 0.7.0.
