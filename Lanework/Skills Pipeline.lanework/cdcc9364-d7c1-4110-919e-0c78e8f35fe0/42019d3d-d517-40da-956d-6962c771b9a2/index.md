---
schema: 1
kind: card
title: "Watch and dispatch: read a move receipt as the move it records"
order: 7168
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T01:22:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-12T01:22:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
On a board whose `config` sets `move-receipts: true`, the app posts a comment signed `by: {name: board, kind: agent}` with a `moved:` key whenever a card changes lane in the app (guide § Stamping your work, "One more name the app reserves"). The watch and dispatch rules were written before receipts and describe an owner's move as "a bare move with no comment".

## Gap

- `watch/references/events.md:11` (item 5): "A bare move with no comment = the owner acting at a gate". With receipts on, an app move arrives with a new comment, so the wording no longer matches what the watcher sees.
- Item 4 classifies a comment by `created.by`: the receipt is `kind: agent`, so it is ignored, which is right for replying but loses the one fact the receipt carries, `moved.by` (who moved the card).
- `dispatch/scripts/classify-event.sh` decides owner or agent move from stamp age; a receipt states it outright.

## Idea

- Say in `events.md` that a `board`-signed comment with `moved:` is the move's own record: never answered, and `moved.by` names the mover.
- Let `classify-event.sh` read `moved.by` from a receipt when one came with the move, falling back to the stamp-age rule on boards without receipts.

## Touches

`skills/watch/references/events.md`, `skills/dispatch/scripts/classify-event.sh`, `skills/dispatch/references/routing.md` if it restates the rule, `tests/smoke.sh` (a receipt fixture and a classify case), README § Sizes.

## Open for shaping

- The exact shape of `moved:` and whether a Shortcuts move writes the same receipt: read the guide and a real receipt first. Neither board in this repo has `move-receipts` on.
