---
schema: 1
kind: card
title: "Smoke is red: the board's guide moved to v93, the skills are stamped v84"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}, {text: merge, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-13T15:18:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-13T15:18:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The Lanework app rewrote this board's guide to `lanework-agent-guide v93`, nine versions past the skills' `v84` stamp, so smoke's stamp gate fails on main. Unlike v83 and v84 this move has real drift.

## What v93 changed (diff of the board's `CLAUDE.md`, 86+ / 68−)

- **Board-shipped heal**: `.schema/bin/lanework-heal.py` and `.schema/HEAL.md`. "The copy an agent skill carries refuses a board that ships its own."
- **Tracker sync removed**: the "no tracker engine" section, its reserved names (`remote`, `remote-state`, `state` kind, `.tracker.nosync/`) and the `tracker` signer are all gone.
- **Retired**: `config.collapse-empty`, and machine-level `default-labels` (a board's vocabulary is its own `config.labels` alone).
- **Single-kind repair** keeps the lowest `rank`, not the first in file order.
- **`waiting` clears** on a reply `in-reply-to` the ask too. An agent's reply never clears it.
- **A "four rules before you write" preamble**, and empty drop sections during a drag on a closed single kind (presentation only).

## Already matched on main

`03a4252` (`--global` and `default-labels` dropped), `49ffedd` (numeric-string rank), `d8deb57` (lowest-rank single-kind repair). `collapse-empty` and `default-labels` appear nowhere under `skills/`.

## Drift to check and fix

- **Tracker**: `lanework/references/writes.md` § Tracker boards, the tracker clause in `watch/references/events.md` item 4, `merge/references/rules.md` and `merge/scripts/lanework-merge.py` (`remote-state`, `state`). Decide: drop the tracker text, or keep it as preserved-bytes handling for boards from older builds.
- **Heal precedence**: `lanework/references/writes.md` § Healing and `lanework/scripts/heal-board.py`, checked against "the board's copy wins".
- **`waiting`**: `work/references/writing.md` § The ask, checked against the new clearing rule.
- **Stamp**: bump `lanework-agent-guide v84` to `v93` in the repo `CLAUDE.md` once the above is read through, and commit the app's guide twins.

## Done when

Every skill reads true against guide v93, smoke passes with the stamp case reading v93, and `tests/check-sizes.sh` reports 0 wrong.
