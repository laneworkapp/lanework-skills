---
schema: 1
kind: card
title: "The board format keeps unknown keys and has no claim key"
order: 1024
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: F1
---
The app keeps a card frontmatter key it does not know, through every rewrite, and does not draw it. The guide names `claimed-by:` as an example of such a key. Nothing in the guide marks a card as taken: no key, no lane, no comment shape. The same was found at guide v102 in [Fact: the board format has no claim or presence, and keeps unknown keys](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/da63a42c-f5f7-4d48-9cd6-d586800e0d78).

Not tested: whether the app, with a card open, can write back an older copy of the file and so undo a change an agent made to an unknown key.

## Source

- This board's `CLAUDE.md` (guide v117) § Frontmatter, lines 724 to 726, read 2026-11-14
- `.schema/card.json`, `additionalProperties: true`, read 2026-11-14

## Bears on

- Staking and renewal: not asked yet
