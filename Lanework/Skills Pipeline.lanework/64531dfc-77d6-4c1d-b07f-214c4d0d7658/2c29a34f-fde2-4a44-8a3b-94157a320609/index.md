---
schema: 1
kind: card
title: "Skills target agent guide v107: waiting.for lists, short lanework links"
order: 3072
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}, {text: plan, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-06T00:08:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-11-12T00:39:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
The skills are stamped `lanework-agent-guide v101`, and this board's guide is v106, so smoke fails on the stamp gate. Two app changes since then need skill wording. The owner asked for both through the Lanework Pitwall session on 2026-11-05, from Lanework Pipeline cards 37a19646 and 418c0af0.

## Changes

- **`waiting.for` may be a list (guide v105).** `waiting: {for: [rzen, other], since, comment}`. In `work/references/writing.md`: a list only on boards whose guide is v105 or later, an `@`-mention for each handle in the ask, and any listed person's answer clears the mark. `work/templates/ask.md` shows the list form next to the single one. `work/scripts/lint-ask.sh` accepts several handles and requires an `@` for each. The discovery and plan scripts that read `waiting.for` accept a list or a string.
- **Short `lanework://` links (guide v107).** In the app, Copy Lanework Link now writes each segment as only the first 8 or more hex digits. In `work/references/writing.md` § Card references: read a short link by prefix (the board whose `id` starts with it, then the one lane, card or comment folder whose name does), and write the full form yourself. The plan scripts keep matching full ids only.
- **The read-through.** Read every skill against the current guide, fix the drift, re-copy `tests/fixtures/app-writes/`, then bump the stamp in `CLAUDE.md`. The stamp lands on v107 only once this board's guide reaches it; until then, v106.

## Touches

`skills/work/references/writing.md`, `skills/work/templates/ask.md`, `skills/work/scripts/lint-ask.sh`, `skills/discovery/scripts/*.sh` and `skills/plan/scripts/*.sh` where they read `waiting`, `tests/fixtures/app-writes/`, `tests/smoke.sh`, `CLAUDE.md` (stamp), `README.md` § Sizes.

## Verify

`tests/smoke.sh` passes, with new cases: `lint-ask.sh` passes a list-form `waiting` with an `@` for each handle and fails one with a handle missing, and each script that reads `waiting.for` handles a list.

## Done when

The stamp matches this board's guide, smoke is green, and the skills read a list-form `waiting.for` and a short link.
