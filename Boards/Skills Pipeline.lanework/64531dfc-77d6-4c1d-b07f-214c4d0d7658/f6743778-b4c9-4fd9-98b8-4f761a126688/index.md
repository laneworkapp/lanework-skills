---
schema: 1
kind: card
title: "A brace, quote or backslash in a stamp value can still write invalid front matter"
order: 2048
created:  {at: 2026-11-20T23:06:30Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T13:15:44Z}
---
## Problem

A stamp value can still produce invalid front matter. Left open when `b4dfd24b` closed (reviewer notes; all behave the same before that card):

- `--name '{n}'`: braces balance, so `stamp_lines_ok` passes it and an invalid stamp is written. `move-card.sh` then exits 1 from its post-write validation with the card left invalid; `post-comment.sh` exits 0 with an invalid comment.
- A double quote or backslash in `--session` (`a"b`, `a\`) writes an invalid stamp through both scripts.
- Restamps that pass the stamp through `awk -v` (`move-card`, `settle-question`, `claim-ticket`, `resolve-ticket`) unescape backslashes, so they write a different session string than `post-comment.sh` does for the same argument.
- `found-board.sh` writes its stamps without calling `stamp_lines_ok`.

## Wanted

One place decides what a name, model and session may contain and how each is written, and every script uses it, so the same argument gives the same valid stamp everywhere or is refused before anything is written.

## Done when

- For each of `{n}`, `a"b`, `a\`, `a\"}}}` as name, model and session: every stamp-writing script either refuses with nothing written, or writes a stamp the board validator accepts and that is byte-identical across scripts.
- `found-board.sh` goes through the same check.
- A smoke case per value and script.
