---
schema: 1
kind: card
title: "Smoke is red: the board's guide moved to v101, the skills are stamped v93"
order: 49152
labels: [{text: repo, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T10:44:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T11:33:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The Lanework app rewrote this board's guide to `lanework-agent-guide v101`, eight versions past the skills' `v93` stamp. Smoke's stamp gate now fails on main, and that blocks the 0.7.0 release.

## What v101 changed (board `CLAUDE.md` diff, committed in `9a12b5d`)

- **Only the compact form is written.** A list or mapping stays on one flow line while it fits 120 characters. Past that it is `key:` over a block, with each nested entry on one line where its own line fits. Stamps are always one line. Other layouts still read, but the board's heal rewrites them (new rule H17 `compact-collection`). v93 said "write whichever suits you".
- **Lane `card-defaults.labels`** may hold full kinded entries, re-stamped at birth, and a card's own value of a `single` kind wins. Board Settings edits the key.
- **Board Settings now writes** `due-soon`, `labels` kinds (re-stamping cards on Save), `thumb-sizes` and `logging`. "No control in the app" is gone.
- **The effective vocabulary** is `config.labels` plus the built-in `text` kind (a wording change only).
- **Board heal v2** (`lanework-heal.py`, `HEAL.md` catalog v2): adds H17, writes rewritten keys compact instead of keeping block, keeps a comment on the key's line, keeps a plain app timestamp plain, drops `--global`, and clarifies H11's skip.
- **The `.gitignore` seed v5** drops `.tracker.nosync/`.
- Also: a "Where to get Lanework" paragraph, and a grouped lane opening a new card in its kind's section. Neither touches the skills.

## Fix

- **Writers emit compact**: `lib.sh` `compact_fm` runs the skill heal's layout pass on a staged file. `found-board.sh` (and the discovery and plan founders through it), `file-ticket.sh` and `file-record.sh` call it.
- **Heal mirrors H17**: `heal-board.py` gains `compact-collection` with v2's guards (a key written twice, a comment inside the value, a block scalar, an anchor, an alias or a tag are left alone). It also keeps a key-line comment and a plain app timestamp. Its output is byte-identical to the board heal's, apart from stamp spacing.
- **Merge writes compact**: `lanework-merge.py` writes merged `labels` and `config` in the compact form. `config` used to be fully block.
- **Prose**: `writes.md` gains a compact-form bullet. Its card-defaults bullet covers kinded entries and the card's own `single` value winning. `.tracker.nosync/` is no longer git-ignored, and layout joins the heal's repairs. In `format.md`, `.tracker.nosync/` comes off the app-owned list.
- **Stamp**: `lanework-agent-guide v93` → `v101` in the repo `CLAUDE.md`. The schema stays at v1.
- **No change needed**: Board Settings, `due-soon`, `thumb-sizes`, `logging` and the `text` wording. No skill restated them. The merge `.gitignore` version rule reads v5, and `--global` was already gone.

## Touches

`skills/lanework/scripts/heal-board.py`, `skills/lanework/scripts/lib.sh`, `skills/lanework/scripts/found-board.sh`, `skills/plan/scripts/file-ticket.sh`, `skills/discovery/scripts/file-record.sh`, `skills/merge/scripts/lanework-merge.py`, `skills/lanework/references/writes.md`, `skills/lanework/references/format.md`, `CLAUDE.md` (stamp), `README.md` § Sizes, `tests/smoke.sh`, `tests/merge-case.sh`.

## Verify

`tests/smoke.sh` passes on a checkout whose board guide is v101, with the stamp case reading v101. `tests/check-sizes.sh` reports 0 wrong. Prose read through against guide v101.

## Done when

Every skill reads true against guide v101, smoke passes with the stamp case reading v101, and the release gate no longer blocks 0.7.0.
