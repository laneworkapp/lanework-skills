---
schema: 1
kind: card
title: "An approved card sat in Approved: the watch read a build queue move as needing a chat go-ahead"
order: 27648
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T00:44:55Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T00:44:55Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The owner moved a card into Approved, and the watch asked in chat whether to build it instead of building it.

**Reproduce**: watch a pipeline board. The owner drags a Proposed card to Approved with no comment. The watch surfaces it and waits.
**Cause**: `watch/references/events.md` step 5 said act only when "the user's standing instructions cover it", read as chat. The Approved lane body never said approval is the go-ahead.
**Fix**: events.md says standing instructions are the board sheet and lane bodies, and a move into a lane that hands work to agents is the work order. `lanework/templates/pipeline-lanes.md` and this board's Approved lane say approving a card is the go-ahead.
**Done when**: both say so, and smoke passes.
