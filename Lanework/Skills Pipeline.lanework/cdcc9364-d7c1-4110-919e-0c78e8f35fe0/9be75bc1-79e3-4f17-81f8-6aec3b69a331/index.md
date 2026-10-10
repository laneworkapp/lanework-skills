---
schema: 1
kind: card
title: "heal and board-kinds: follow-ups from the lane-actors review"
order: 3072
labels: [{text: heal, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T02:41:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T02:41:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
Three small gaps the review of [0d374675](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0d374675-f23c-4959-95dc-07e10f99d345) left as notes, none blocking.

- **Asked vs the gate key**: `board-kinds.md` defines a gate as "agents move cards in only", but discovery's Asked row has the agent move a card out once ruled. Reword the key or the row.
- **drop-stale context**: `heal-descriptors.py` removes "A chore the owner files in Tasks has passed both." wherever it appears. As a bullet of its own it leaves a bare `-`, and it would also hit a quote or a fence. Anchor it to the gates bullet, or drop the whole line when nothing else is on it.
- **Ideas in two sweep rows**: `work/references/sweep.md` lists Ideas under both "At a human gate" and "Holding", so a sweep can count it twice.
- **Done when**: each is fixed or ruled out, with a smoke case for the drop-stale fix.
