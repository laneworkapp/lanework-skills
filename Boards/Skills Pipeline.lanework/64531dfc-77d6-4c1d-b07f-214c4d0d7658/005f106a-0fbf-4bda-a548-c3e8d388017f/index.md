---
schema: 1
kind: card
title: "settle-question.sh settles on a Recap click, against rounds.md"
order: 1024
labels: [{text: "discovery", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T16:42:56Z}
---
Reviewer note from `c7379e38`, not fixed there.

## Problem

`skills/discovery/references/rounds.md:34` says a `Recap:` click is not an answer. `settle-question.sh` with no `--record` still settles a waiting card whose only owner comment is a Recap click, because `lint-waiting-clears.sh` counts any later human comment as an answer.

## To shape

- Reproduce on a throwaway discovery board: one ask, one owner comment starting `Recap:`, then `settle-question.sh` with no `--record`.
- Decide where the rule lives: the lint (a `Recap:` comment does not clear), or the settle script.
- A smoke case that fails on today's code.
