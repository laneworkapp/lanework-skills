---
schema: 1
kind: card
title: "Asks no longer need a leading handle once the app draws buttons without one"
order: 3072
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-20T02:07:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-20T11:59:06Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
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

## An ask with no options

An ask with no options ("Run the trial, then reply here") has fewer than two option lines, so the app's new rule does not see it as a question. It keeps `@anyone`, which keeps it in the questions chip and filter.

## Decided

Ruled by the owner on this card, 2026-11-20: **A, optional.**

- An ask with options: no handle by default.
- An ask for a named person: their handle stays on line 1.
- An ask with no options: keeps `@anyone`.
- Not taken: B (`@anyone` stays the default, only the checks relax) and C (removed everywhere, named people included).

## Risks

- **Older builds**: an app without the change draws no buttons on a handle-free ask. Covered by the guide-version gate; below the gate the skills write the handle as today.
- **The rule is second-hand**: read from a relay, not the app's source or a guide. The build checks it against the guide that states it before writing code.
- **Lint reach**: telling an ask by the app's rule means a record that happens to hold two option-shaped lines and a question mark on line 1 gets linted as an ask. Accepted: such a record draws buttons in the app too, so it should read as an ask.

## Waits on

A released app build that carries the change, and the board guide stating the rule. The skills follow the in-board guide; v118 still says the handle draws the buttons. Approving this card before then parks it: the build starts when the guide moves.

## Done when

- `work/templates/ask.md` and `work/references/writing.md` § The ask give the three cases above.
- `lint-ask.sh` lints a handle-free ask with options, and still passes a plain record.
- `post-ask.sh` posts a handle-free ask and writes `waiting`; `--for <person>` still requires that handle on line 1.
- On a board below the gating guide version, all three behave as today.
- Smoke has a case for each, and passes.
