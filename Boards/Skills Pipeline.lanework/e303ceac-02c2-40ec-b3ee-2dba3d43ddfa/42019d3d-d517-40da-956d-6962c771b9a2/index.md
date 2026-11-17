---
schema: 1
kind: card
title: "watch: read a move receipt as the move it records"
order: 69632
labels: [{text: watch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T01:22:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-17T16:47:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Watch should treat a move receipt, the `board`-signed comment with a `moved:` key, as the record of a move: never answered, and the source of who moved the card.

Reshaped 2026-11-17 at the owner's ask: the dispatch work is cut, since [Retire the dispatch skill](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/ee07c8d2-6fa8-41ac-b06a-ceb5f3045fd0) removes `classify-event.sh` and its fixture board. What is left is watch's own reading of a receipt.

## Facts (guide v117 and `.schema/common.json`, read)

- A receipt exists only on boards with `config.move-receipts: true`, and is written for a move in the app or through its Shortcuts action, so one receipt shape covers both.
- It is a comment with `by: {name: board, kind: agent}` and `moved: {from: {lane, title}, to: {lane, title}, by: <identity>}`. `moved.by` is absent when no identity is known, which reads as the owner (a missing `by` is the owner).
- A bare `mv` by an agent or the owner writes no receipt, so the rule for a move with no comment stays the fallback.

## Why it still matters without dispatch

`skills/watch/references/events.md` item 5 reads "a bare move with no comment" as the owner acting at a gate. On a board with receipts on, a move in the app always arrives with a comment, the receipt, so that rule never matches and the watch has no stated way to tell whose move it was.

## Change

- `skills/watch/references/events.md` item 4: a comment with `moved:` as a mapping is a receipt. Record only, never replied to, whoever signed it. Item 5: "a bare move with no comment" becomes "a move with no reply owed"; when a receipt came with it, `moved.by` names the mover (no `moved.by`, a human or Shortcuts means the owner acting; an agent identity means an agent's move, which is context). Read the receipt from the card's `comments/` on disk, not only from the event's paths, since the two can arrive in separate notifications. Item 6 stays untouched (smoke greps it).
- `tests/smoke.sh`: one prose case beside the existing watch checks (line 1008).
- `README.md` § Sizes: the `watch` events row, its skill total and the summary row, re-measured with `wc -w` (`tests/check-sizes.sh`).
- `CHANGELOG.md`: one user-facing entry at release time, not part of this card.

No script changes. `arm-pass.sh` already counts a `board`-signed comment for nothing, and watch has no event classifier.

## Verified by

- `tests/smoke.sh` green with one new case, `watch events: a move receipt is a record and moved.by names the mover`: a grep that item 4 of `events.md` names `moved:` and item 5 names `moved.by` and no longer says "bare move with no comment". The existing check that item 6 does not say "a move" still passes.
- `tests/check-sizes.sh` and `tests/check-refs.sh` pass.
- The prose is read against this board's guide, § Stamping your work.
- Not verifiable in smoke: that a watch session reads a live receipt this way. The first move in the app on a board with receipts on, under a running watch, is the check; its outcome goes in the closing comment if one happens during the build, and is named as unchecked otherwise.

## Done when

- [ ] `events.md` items 4 and 5 describe a receipt as a record with `moved.by` as the mover, and no longer say "bare move with no comment".
- [ ] The smoke case above exists and `tests/smoke.sh` passes, with the output quoted in the closing comment.
- [ ] README § Sizes matches `wc -w`.

## Risks

- Prose only: nothing runs the rule, so a watch session can still misread a receipt. The smoke case pins the wording, not the behavior.
- Receipt shape could change in a later guide: the rule reads only `moved` as a mapping and `moved.by`, and falls back to the no-comment rule otherwise.

## Depends on

Nothing. [Retire the dispatch skill](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/ee07c8d2-6fa8-41ac-b06a-ceb5f3045fd0) does not touch `events.md` items 4 to 6, so the two can land in either order.

## Recommendation

Build as written: two sentences of prose and one smoke case. No open call.
