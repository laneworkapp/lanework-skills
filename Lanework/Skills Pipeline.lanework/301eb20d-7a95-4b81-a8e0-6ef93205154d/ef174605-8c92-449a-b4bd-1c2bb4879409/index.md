---
schema: 1
kind: card
title: "Smoke is red: the board's guide moved to v93, the skills are stamped v84"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}, {text: merge, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-13T15:18:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-13T15:21:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
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

## Fix

- **Tracker, decided: preserve, never engine.** v93 has no tracker engine and no reserved-name list. Boards from older builds may still carry the keys, and the app keeps unknown keys byte for byte.
  - `lanework/references/writes.md` § Tracker boards → one bullet: tracker keys (`remote`, `remote-state`, a `state` label kind, `.tracker.nosync/`) found on a board are preserved bytes, never written, edited or copied. The engine-off/on branches go, along with their detection by a guide sentence v93 no longer has.
  - `watch/references/events.md` item 4 and `work/references/writing.md` § Record vs ask: the "Tracker board, engine on" clauses go.
  - `merge/references/rules.md` and `lanework-merge.py`: unchanged. "Tracker keys → ours" is preserved-bytes handling and still right.
- **`waiting`**: `work/references/writing.md` § The ask, line 51 → the app clears it once a human comment lands after `since`, or replies to the ask by `in-reply-to`. An agent's reply never clears it.
- **Heal precedence**: no change. `writes.md` § Healing already says the board's `lanework-heal.py` wins and the skill's copy refuses beside it.
- **Retired keys**: no change. `collapse-empty` and `default-labels` appear nowhere under `skills/`.
- **Stamp**: `lanework-agent-guide v84` → `v93` in the repo `CLAUDE.md`, plus the app's guide twins committed as a board write.

## Touches

`skills/lanework/references/writes.md`, `skills/watch/references/events.md`, `skills/work/references/writing.md`, `CLAUDE.md` (stamp), `README.md` § Sizes (re-measured with `tests/check-sizes.sh`).

## Verify

`tests/smoke.sh` passes with the stamp case reading v93. `grep -rn -i "engine on\|tracker engine" skills` finds nothing. Prose read through against guide v93.

## Done when

Every skill reads true against guide v93, smoke passes with the stamp case reading v93, and `tests/check-sizes.sh` reports 0 wrong.
