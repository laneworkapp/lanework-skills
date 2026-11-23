---
schema: 1
kind: card
title: "An owner-pasted comment holds an email address in the public repo: left as is"
order: 103424
labels: [{text: "repo", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T20:04:16Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T23:32:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
A comment on this board, in the public repo, carries the owner's git email address in a pasted `Author:` line. The owner's ruling: no big deal, leave it be. This card records it so it is not raised again.

## Where

- Card `702953a4` (Move the owner's install to lanework-marketplace), comment `2c5716a9`, line 10: a pasted `dotfiles` log excerpt.
- Added in commit `eb446be` (2026-11-18), which is on `main` and `stable`.

## Ruling

> its no big deal, lets leave it be

Nothing is edited and history is not rewritten.

## Proposal

Close this card as a record, with no change to the board, the repo or the skills.

- **No edit to the comment.** Blanking the address would remove it from the latest tree only. It stays readable in git history.
- **No history rewrite.** That means rewriting `main` and `stable` and force-pushing a published plugin, and hosted caches may keep copies.
- **No guard.** A check that flags an email address before a board commit was floated at filing. Not recommended: one occurrence, already ruled harmless, and the check would flag every pasted log an owner posts on purpose.

Files touched: none.

## Risks

None from closing. The address stays public, as ruled.

## Verification

Nothing to run.

## Done when

The card is in Done with this body. No file outside the card changes.

## Open calls

None. Approving this proposal closes the card. Rejecting it with a comment naming the guard reopens that one point.
