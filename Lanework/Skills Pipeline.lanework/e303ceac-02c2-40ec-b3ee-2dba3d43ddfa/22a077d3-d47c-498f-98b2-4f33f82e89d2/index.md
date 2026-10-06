---
schema: 1
kind: card
title: "Turn every open owner choice into an ask on the card"
order: 14336
labels: [{text: pitlane, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-01T11:04:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T11:07:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The skills explain how to write an ask, but never say when a choice must become one, so a choice that only the owner can make gets left in a card body or asked in the terminal, and is never ruled on the card.

## Reproduce

Sweep a pipeline board that has a Shaping card needing an owner choice between options. Following `sweep.md`, `farmed-prompt.md` and `board-kinds.md` as written, the shaper lists the options in the body and posts no ask, because review out of Proposed reads as the place choices get made. The owner approves the card, which moves it but rules nothing, and it reaches Approved with an unruled choice and no `waiting`.

## Change

- `lanework/references/board-kinds.md` § Pipeline, Moves: review approves the card, not its open calls. An open call is ruled only through an ask on the card.
- `pitlane/references/writing.md`: a short "When to ask" section. Any call only the owner can make (between options, a taste call, scope) → a record laying out the options, then an ask 1s later with the options as buttons and the recommendation marked, and `waiting` set. The body keeps the options under an open-call line, which the ruling edits in place. Never body-only, record-only, or chat-only.
- `pitlane/references/sweep.md`: the Shaping row becomes "shape; any open call → ask". A new workload, "Approved with an unruled open call": don't build it; post or re-post the ask and report it.
- `pitlane/templates/farmed-prompt.md`: give the "usual offenders" note its fix, a Task line telling shapers that an owner choice becomes a record plus a linted ask with `waiting`.
- `pitlane/references/companions.md` or `sweep.md` § 3: with the owner in a live chat, the ask still goes on the card, where the ruling is recorded. The chat only links to it. No build until a ruling comment exists.

## Done when

- Each file above carries its rule once, and the others link to `writing.md` rather than restating it.
- `tests/smoke.sh` passes, and README sizes are recounted.
