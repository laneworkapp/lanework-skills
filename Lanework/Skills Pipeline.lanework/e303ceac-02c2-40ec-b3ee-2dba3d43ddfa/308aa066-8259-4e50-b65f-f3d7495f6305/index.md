---
schema: 1
kind: card
title: "Shaping to Proposed is the agent's move, but no file says so"
order: -1024
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: work, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-09T23:54:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-09T23:56:11Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
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

- `board-kinds.md` § Moves: state Shaping to Proposed as the shaper's move, made once the body meets the bar and every open call is ruled.
- `work/SKILL.md`: the shape clause ends with that move.
- `watch/references/responding.md`: a ruling that closes a Shaping card's last open call moves it in the same pass.
- `lanework/templates/pipeline-lanes.md`: Shaping and Proposed bodies say who moves a card in and who moves it out. Same text on this board's two lanes.

## Verify

`tests/smoke.sh` passes. Prose read through against guide v82.

## Done when

Each of the four files states the move, and this board's Shaping and Proposed lane bodies match the template.
