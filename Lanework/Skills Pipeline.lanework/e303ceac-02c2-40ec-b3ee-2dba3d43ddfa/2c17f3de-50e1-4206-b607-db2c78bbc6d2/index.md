---
schema: 1
kind: card
title: "Design-loop and discovery lanes ship with icons"
order: 39936
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T11:56:10Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T11:56:10Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
Follow-on to c8cf1d23 at the owner's ask: the design-loop and discovery lanes tables fill their `icon` column too. The tint rule is the same. Smoky tangerine marks a lane that waits on the owner, as Proposed does on a pipeline.

| set | lane | glyph | tint |
|---|---|---|---|
| design loop | Brief | doc.text | |
| design loop | Alternatives | arrow.triangle.branch | |
| design loop | Mockups | paintbrush | |
| design loop | Sittings | person.2 | smokey-tangerine |
| design loop | Chosen | star | |
| design loop | Dead ends | xmark.circle | |
| discovery | Brief | doc.text | |
| discovery | Facts | doc.text.magnifyingglass | |
| discovery | Asked | questionmark.bubble | smokey-tangerine |
| discovery | Settled | checkmark.bubble | |
| discovery | Decisions | signpost.right | |
| discovery | Parked | parkingsign.circle | |

The datapoint lanes stay without icons.

**Done when**: founded design-loop and discovery boards carry the set and validate, and smoke passes.
