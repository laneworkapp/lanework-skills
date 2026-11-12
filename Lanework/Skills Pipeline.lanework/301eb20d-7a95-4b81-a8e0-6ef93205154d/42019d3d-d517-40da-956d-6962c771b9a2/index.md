---
schema: 1
kind: card
title: "Watch and dispatch: read a move receipt as the move it records"
order: 1024
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T01:22:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-12T18:57:09Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
Watch and dispatch should treat a move receipt, the `board`-signed comment with a `moved:` key, as the record of a move: never answered, and the source of who moved the card.

## Facts (guide v117 and `.schema/common.json`, read)

- A receipt exists only on boards with `config.move-receipts: true`, and is written for a move in the app or through its Shortcuts action, so one receipt shape covers both.
- It is a comment with `by: {name: board, kind: agent}` and `moved: {from: {lane, title}, to: {lane, title}, by: <identity>}`. `moved.by` is absent when no identity is known, which reads as the owner (a missing `by` is the owner).
- A bare `mv` by an agent or the owner writes no receipt, so the stamp-age rule stays the fallback.

## Change

- `skills/watch/references/events.md` item 4: a comment with `moved:` as a mapping is a receipt. Record only, never replied to, whoever signed it. Item 5: "a bare move with no comment" becomes "a move with no reply owed"; when a receipt came with it, `moved.by` names the mover (human or Shortcuts means the owner acting). Item 6 stays untouched (smoke greps it).
- `skills/dispatch/scripts/classify-event.sh`: for a moved card, look in its comments for a receipt whose `moved.to.lane` is the card's current lane and whose `created.at` is under `MOVE_FRESH` seconds old. Found: the move's author is `moved.by` classed owner (no `by`, or `kind: human`) or agent. Not found: the existing stamp-age rule. A receipt is never printed as a `comment` line. Header comment of the script updated to say so.
- `skills/dispatch/references/routing.md` restates only events.md items 1 to 2, so it is read and left alone unless that changes.
- `tests/smoke.sh`: a receipt helper and cases beside the existing move cases (below).
- `README.md` § Sizes: the `watch` events row, its skill total and the summary row, re-measured with `wc -w` (`tests/check-sizes.sh`).
- `CHANGELOG.md`: one user-facing entry at release time, not part of this card.

## Verified by

- `bash -n` on `classify-event.sh`, then `tests/smoke.sh` green with these new cases on a throwaway dispatch fixture board (never this board):
  - a moved card plus a fresh receipt with `moved.by` a human: `move ... owner`, and no `comment` line for the receipt;
  - the same with `moved.by` an agent identity: `move ... agent`;
  - a receipt with no `moved.by`: `move ... owner`;
  - a receipt older than `MOVE_FRESH`, or whose `to.lane` is not the current lane: ignored, stamp-age rule applies;
  - a receipt arriving alone in a burst (no move paths): prints nothing;
  - every existing move and comment case unchanged.
- `tests/check-sizes.sh` and `tests/check-refs.sh` pass. The prose change is read against guide v117 § Stamping your work (the stamp in CLAUDE.md is v114; the guide-move card owns that).

## Done when

- [ ] `events.md` items 4 and 5 describe a receipt as a record with `moved.by` as the mover, and no longer say "bare move with no comment".
- [ ] `classify-event.sh` prints the mover from a fresh matching receipt and prints no line for a receipt itself.
- [ ] The six smoke cases above exist and `tests/smoke.sh` passes, with the output quoted in the closing comment.
- [ ] README § Sizes matches `wc -w`.

## Risks

- A receipt that lands in a later burst than its move: the move was already classed by stamp age, so the improvement is lost but nothing breaks. Reading it from disk (not only from the burst's paths) catches the common case where both arrive together.
- Receipt shape could change in a later guide: the classifier reads only `moved` as a mapping and `moved.by`, and falls back otherwise.
- `yq` parse of a malformed receipt must fail soft to the fallback, as `stamp()` does.

## Recommendation

Build as written: small, read-side only, and no open call remains (the shape and the Shortcuts question are answered by the guide).
