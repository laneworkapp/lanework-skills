---
schema: 1
kind: card
title: "An ask posted without waiting on its card goes unnoticed by every lint and by the arming pass"
order: 3072
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}, {text: "watch", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-26T12:53:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:46:46Z}
---
An ask can be posted without setting the card's `waiting` key, and nothing in the skills catches it, so the app shows no waiting mark on a card that waits on the owner.

Reported by the session watching the app's Pipeline board, at the owner's word there ("send your research to lw-skills"). It happened on that board's card 1a2818a7: the owner noticed an ask with no waiting mark.

## How it happened there

- The session was armed on plugin 0.7.0, which had no script for posting an ask. It wrote its own helper, which posts the comment and stops.
- `post-ask.sh` arrived in 0.9.0 and sets `waiting` in the same step. The session moved to 0.11.0 and kept its old helper.
- After many context summaries its notes kept the wording rules for an ask and lost the `waiting` step.

## Why nothing caught it

Checked in this repo at 0.11.0:

- `skills/work/scripts/lint-ask.sh` reads the ask's text only. It never sees the card.
- `skills/watch/scripts/arm-pass.sh` classes cards by lease and owner comments. It has no line for an open ask on a card with no `waiting`.
- `skills/work/scripts/lint-waiting-clears.sh` checks a `waiting` that was cleared, not one that was never set.
- `skills/watch/references/responding.md` sends the reader to `writing.md` § The ask and does not name `post-ask.sh`.
- `skills/work/references/sweep.md` has a row for an owner action with no ask, and none for an ask with no `waiting`.

## To reproduce

On a throwaway board, post an ask with `post-comment.sh` in place of `post-ask.sh`. Every lint passes and `arm-pass.sh` prints nothing for the card.

## Suggested by the reporting session

- A lint that fails when a card's newest ask has no human comment after it and the card has no `waiting`, run from `arm-pass.sh` and `commit-board.sh`.
- Name `post-ask.sh` in `watch/references/responding.md`.
- A line telling a long-running watch to re-read the scripts table after a plugin update.

## Done when

- On a throwaway board, an ask posted with no `waiting` on its card is reported by a lint and by the arming pass.
