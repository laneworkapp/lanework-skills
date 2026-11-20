---
schema: 1
kind: card
title: "Asks no longer need a leading handle once the app draws buttons without one"
order: 1024
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-20T02:07:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
waiting: {for: anyone, since: 2026-11-20T02:08:01Z, comment: 9e1c31a5-f5f0-432d-92b6-9c5bf53e36c6}
modified: {at: 2026-11-20T11:57:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The app is changing how it decides that a comment is a question, so an ask will no longer need a handle on its first line to get answer buttons. The skills should follow once that reaches a build, by making the leading handle optional.

## What changed in the app

Reported by the Lanework Watch session on 2026-11-19, at the owner's ask on the app's Pipeline card d722f25c. Not read in the app's source here. Landed on `lanework-app` main as merge `c9eab62c5`; not in a TestFlight build yet (build 13132 lacks it).

- A comment draws answer buttons, for every viewer, when it has at least two option lines (`- Label: text`) and reads as a question: its first line has a question mark, or a line reading exactly `Options:` sits above the options, or its first line begins with any handle.
- `Why now:`, `If no answer:` and `Context:` still end the option list.
- The same rule feeds the unanswered-questions chip, Previous and Next Question, and the Questions filter.
- Unchanged: a mention is what notifies a person. A card's `waiting: {for: …}` mark shows only for the handle it names. Any human reply clears `waiting`.

## What the skills do today (guide v118)

- `work/templates/ask.md` and `work/references/writing.md` § The ask: `@anyone` on line 1 by default, a person's handle for a question that is theirs.
- `work/scripts/lint-ask.sh`: a body that mentions no human is a record and passes unchecked. The handle is how it tells an ask from a record.
- `work/scripts/post-ask.sh`: `--for` is required and must appear on line 1 as `@<handle>`.
- `lanework/scripts/lib.sh` `ask_handle`: `anyone` on a v117 or later board.

## Proposal

- The leading handle becomes optional. An ask with options and a question mark or an `Options:` line needs none. A named person's handle stays, since it notifies them and scopes the `waiting` mark.
- `lint-ask.sh` tells an ask by the app's rule as well as by a handle, so a handle-free ask is still linted.
- `post-ask.sh` accepts a body with no handle and still writes `waiting`.
- Gated on the board's guide version, as `ask_handle` is: older builds draw no buttons without the handle.

## Not covered by the app's rule

An ask with no options ("Run the trial, then reply here") has fewer than two option lines, so the new rule does not see it as a question. Without a handle it has no buttons to lose, but it also drops out of the questions chip and filter. Such an ask keeps `@anyone`, or relies on `waiting` alone. Shaping settles which.

## Waits on

A released app build that carries the change, and the board guide stating the rule. The skills follow the in-board guide; v118 still says the handle draws the buttons.

## Open call

**Open call: how far the handle goes.**
- A (recommended): optional. Dropped by default on an ask with options; kept for a named person and on an ask with no options.
- B: `@anyone` stays the default; the lint and `post-ask.sh` only stop requiring it.
- C: removed everywhere, named people included.
