---
schema: 1
kind: comment
in-reply-to: 7c134b11-cc2c-4e57-b05e-a4e75c127271
created:  {at: 2026-10-25T01:14:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T01:14:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**In short: the merge skill works, but it has never been tested against a file the Lanework app itself wrote. Both options test that automatically. They differ in where the app's files come from.**

- **What's tested today**: two copies of a board, both edited by scripts, then merged. Every kind of clash is covered.
- **What's missing**: the app writes files in its own style. One example is the app saving a card with no `by`. The tests never use a file like that.
- **A, saved copies**: take real files the app already wrote from this board's git history. Keep them in the test folder and use them as one side of the clash. It runs everywhere, CI included. Downside: the copies age, so we refresh them whenever the app's guide version moves.
- **B, the real app**: a Shortcut makes the app write fresh files, then the test merges them. It's always current. Downside: it only runs on your Mac, and the app's Shortcuts can only create, move and comment. They can't edit a card's text.

My pick is still A. The ask above stands.
