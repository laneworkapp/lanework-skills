---
schema: 1
kind: card
title: "Shaping to Proposed is the agent's move, but no file says so"
order: 25600
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: work, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-09T23:54:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T00:00:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
An agent finished shaping a card, then left it in Shaping and told the owner it was theirs to move to Proposed. Moving it is the agent's job. The gate is out of Proposed, not into it.

## Reproduce

Shape a card until its last open call is ruled, watching the board. The agent reports the card as "ready for you to move to Proposed".

## Cause

- `lanework/references/board-kinds.md` § Moves lists only what agents must not move. The agent's own Shaping to Proposed move is implied by "lanes on either side of their own work", never stated.
- The Proposed lane body opens "The human review gate", which reads as gating entry as well as exit.
- `work/SKILL.md` says to shape cards into proposals, and stops there.
- `watch/references/responding.md` folds a ruling without checking whether it was the card's last open call.

## Fix

Who moves a card between lanes is board-specific, so the rule lives in board and lane bodies, never in a skill reference.

- `lanework/templates/pipeline-index.md`: the gates bullet says the agent moves a finished proposal into Proposed. Same text in this board's instruction sheet.
- `lanework/templates/pipeline-lanes.md`: Shaping and Proposed bodies say who moves a card in and who moves it out. Same text on this board's two lanes.
- `work/SKILL.md`: the shape clause ends with moving the card on as the board and lane bodies say.
- `watch/references/responding.md`: a ruling that closes a card's last open call applies its lane exit in the same pass.

## Verify

`tests/smoke.sh` passes. Prose read through against guide v82.

## Done when

Both templates state the move, this board's instruction sheet and two lane bodies match them, and the two skill files point at those bodies without restating the rule.
