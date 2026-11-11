---
schema: 1
kind: card
title: "Discovery map: 💬 for frontier questions, ⏳ for not yet askable"
order: 1024
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-11T23:22:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
modified: {at: 2026-11-11T23:22:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
---
Change two of the discovery map's three status marks. ❓ is a red emoji and reads as an alarm, not "open, your turn". ◦ is a faint text glyph that looks like a second bullet after the list's own.

| state | now | becomes |
|---|---|---|
| settled | ✅ | ✅ (unchanged) |
| on the frontier | ❓ | 💬 |
| not yet askable | ◦ | ⏳ |

## Files

- `skills/discovery/templates/map-card.md`: the legend line and the example tree.
- `skills/discovery/references/rounds.md`: the round post in chat opens with the frontier mark, so it changes with the map.

Existing boards keep their old marks until their map is next rewritten, at a round's close. No migration.

## Verify

`grep -rn -E '❓|◦' skills/` finds nothing. `tests/smoke.sh` passes. Both files read through against the guide version the skills target.

## Done when

The map template and the round post use ✅ 💬 ⏳, and no ❓ or ◦ is left under `skills/`.
