---
schema: 1
kind: card
title: "A card parked on an owner action carries no waiting mark"
order: 4096
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T03:59:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T17:55:04Z}
---
When a card's next step waits on something only the owner can do, such as running a trial, cutting a release or running commands on their machine, the `work` skill should require an ask with `waiting`, so the card shows as waiting on the owner instead of sitting unmarked with a record that says so.

## Reproduce

On 2026-11-14 all three Active cards were left with a record saying "the trial stays with the owner" or "stays in Active until the release", and no ask, so none showed as waiting. A fresh case on 2026-11-17: [Move the owner's install](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/702953a4-79a8-463e-8887-13113c1118fc) sits in Approved, waiting on the owner to run three commands, with the wait stated only in records.

## Grounding

- The in-board guide allows it. § Mentions says `waiting` marks "a card that is blocked on a human's reply", and § Use the thread's ask is "one request for the human", whose first line is "a question, or an imperative". An imperative such as "run these commands, then reply here" is therefore an ask, and an ask sets `waiting` in the same pass.
- Nothing in the skills says so. `work/references/writing.md` § When to ask defines the open call only as a choice ("between options, taste, scope, anything a done-when hangs on"), and `work/references/sweep.md` has no row for an action. Verified on `main` at `210b30f`.

## Files

- `skills/work/references/writing.md`
  - § When to ask: one new bullet, **Owner action**. Something only the owner can do that the card's next step waits on. It is not a choice, so no options, no open-call line in the body and no ruling edit. One imperative ask: `@anyone` on line 1, the action, the card linked, "reply here when done" (only a human comment clears `waiting`), `If no answer: blocked`, `waiting` set in the same pass. A record alone ("stays with the owner") is the miss.
  - The last bullet of § When to ask ("Open call found later") also names an owner action found later.
  - § Short form (pasted verbatim into every farmed prompt): "A choice only the human can make" becomes "A choice or an action only the human can make".
- `skills/work/references/sweep.md`
  - § 2 table: one new row, **Owner action, no ask**. Shows up: any lane, a record leaves the next step to the owner and the card has no `waiting`. Who acts: you. Action: post the ask (`writing.md` § When to ask), report it. The "Active, stalled" row stays as it is.
- `README.md`: the word counts for `writing.md` and `sweep.md`, the `work` total and the `work` summary row, recounted with `wc -w`.
- No other file. `skills/work/SKILL.md` and `templates/farmed-prompt.md` are unchanged: the first speaks of open calls only, and the second pastes the Short form, which changes above. `templates/ask.md` already allows an imperative with no options.

## Verified

- No script changes, so no new `tests/smoke.sh` case. Nothing in smoke asserts the text of these two files, so the prose is read through against the guide's § Mentions and § Use the thread.
- `tests/smoke.sh` passes, which runs `tests/check-refs.sh` (every path the new text cites must exist: `writing.md` and `sweep.md` are already cited) and `tests/check-sizes.sh` (fails until the README counts match `wc -w`).
- A draft owner-action ask, an imperative with no options and `@anyone` on line 1, run through the installed `work/scripts/lint-ask.sh` against this board, exits 0.

## Done when

- `writing.md` § When to ask carries the Owner action bullet, and the Short form says "choice or an action".
- `sweep.md` § 2 carries the new row, and no other file restates the rule.
- `grep -n "owner action" skills/work/references/*.md` finds the rule once in each of the two files.
- `tests/smoke.sh` is green, with the README counts recounted.

## Risks

- Only the app clears `waiting`, and only when a human comments after `since`. If the owner does the action and says nothing, the mark stays. The ask's "reply here when done" is the mitigation. An agent must not remove it.
- `writing.md` and `sweep.md` are also edited by the guide-v118 build, so a build before it lands conflicts. The `writing.md` change is one bullet and one phrase, away from that branch's edits.
- A chat-only action is not an owner action here: the `heal` skill's rule that the user's own go in chat is no open call on a card is unchanged.
- The wording could read as covering any task an agent could run itself. The bullet says "only the owner can do".

## Depends on

- [Skills target agent guide v117/v118](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8), branch `guide-v118-anyone`: builds after it lands. On that branch `writing.md` already says `@anyone` on line 1 and `for: anyone`, which the new bullet relies on. Its Short form line differs from `main`, so edit the landed text.
- Extends [Turn every open owner choice into an ask on the card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/22a077d3-d47c-498f-98b2-4f33f82e89d2), which is done.

## Recommendation

Build it as above, after the guide-v118 branch lands, with a changelog entry, a minor bump (new behavior), at the owner's call. The change is small, needs no new section, and fixes a case that has now happened twice.

## Open calls

None.
