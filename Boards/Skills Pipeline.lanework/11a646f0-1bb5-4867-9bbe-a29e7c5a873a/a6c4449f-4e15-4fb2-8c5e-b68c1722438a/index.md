---
schema: 1
kind: card
title: "An owner-pasted comment holds an email address in the public repo: left as is"
order: 2048
labels: [{text: "repo", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T20:04:16Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T20:04:16Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
A comment on this board, in the public repo, carries the owner's git email address in a pasted `Author:` line. The owner's ruling: no big deal, leave it be. This card records it so it is not raised again.

## Where

- Card `702953a4` (Move the owner's install to lanework-marketplace), comment `2c5716a9`, line 10: a pasted `dotfiles` log excerpt.
- Added in commit `eb446be` (2026-11-18), which is on `main` and `stable`.

## Ruling

> its no big deal, lets leave it be

Nothing is edited and history is not rewritten.

## If that ever changes

- Blanking the address in the comment file removes it from the board and the latest tree. It stays readable in git history.
- Removing it from history means rewriting `main` and `stable` and force-pushing a published plugin, and hosted caches may keep copies.

## A possible guard, not asked for

A check before a board commit that flags an email address in a pasted comment would catch the next one. Triage decides whether that is worth a card of its own.
