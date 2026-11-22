---
schema: 1
kind: card
title: "Pick the next card by priority"
order: 1024
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-22T22:33:00Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T22:33:00Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Owner's suggestion, in chat 2026-11-22: "use priority when picking next card to work on".

When an agent has several cards waiting in a lane it acts on, it should take the highest-priority one first, wherever the pick happens: a sweep, a watch, a dispatch, shaping or a build.

## Evidence

- `skills/work/references/lead.md` § Order the work already says: build-blockers first, "then the card's priority, as the board's guide defines it, then lane order". That is the only place the rule is stated, and it covers a multi-card build campaign only.
- `skills/work/references/sweep.md`, the `watch` references and `dispatch/SKILL.md` state no pick order. A session shaping from Shaping or building from Approved one card at a time has no rule to follow.
- `skills/lanework/scripts/read-board.sh` prints no labels (no match for `label` or `rank` in the script), so the one-pass board read an agent starts from does not show priority at all.
- The guide defines priority as the card's `labels` entry of kind `priority` with a stamped `rank`, lower rank = higher priority; a card with no priority or no readable rank sorts last ("No priority").

## Done when

- The pick order is stated once, in one file, and `lead.md`, `sweep.md`, `watch` and `dispatch` link to it: priority by stamped rank, then lane order; no priority sorts last.
- `read-board.sh` shows each card's priority, so the order can be followed from the board read.
- A smoke case covers the reader's priority output on a throwaway board.
- Agents still never assign or change a priority: that stays the owner's call (`sweep.md`).

## Open for shaping

- Whether a build-blocker (red gate on main) still comes ahead of priority everywhere, as `lead.md` has it today. Proposed: yes.
- Whether a card already in Active is finished before a higher-priority card in Approved is started. Proposed: yes, work in progress is not dropped for a new arrival.
