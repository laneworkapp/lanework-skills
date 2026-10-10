---
schema: 1
kind: card
title: "Pipeline lanes ship with icons"
order: 37888
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: heal, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T11:28:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T11:38:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
A founded pipeline board's lanes carry no icon, so every lane draws the app's default symbol. The owner asked for a glyph per lane, with a tint only where it says something the glyph can't.

**Set** (owner, 2026-10-10):

| lane | glyph | tint |
|---|---|---|
| Ideas | lightbulb | |
| Issues | exclamationmark.triangle | carnation: broken |
| Tasks | checklist | |
| Shaping | pencil.and.ruler | |
| Proposed | hand.raised | smokey-tangerine: waits on the owner |
| Approved | checkmark.seal | |
| Active | hammer | |
| Done | checkmark.circle | |

**Change**: an `icon` column in the lanes tables (`lanework/templates/*-lanes.md`, `discovery/templates/lanes.md`), between `collapsed` and `body`, holding the `icon` mapping as written. `found-board.sh` writes it on each lane; `heal-descriptors.py` and smoke read the body from its new column. Only the pipeline table fills it. This board's lanes get the same set by hand.

**Done when**: a founded pipeline board's lanes carry the set and validate, the other lane sets found unchanged, and smoke passes up to its stamp gate (red on main from the v84 issue).
