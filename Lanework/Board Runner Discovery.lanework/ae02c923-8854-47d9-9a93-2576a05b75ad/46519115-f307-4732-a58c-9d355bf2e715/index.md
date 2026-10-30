---
schema: 1
kind: card
title: "Q15: Pausing the runner, stopping a card"
order: 7168
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:20Z, comment: 3b408ebe-1395-4b46-8695-37f01376b4d0}
created:  {at: 2026-10-30T15:30:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:20Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
How does the owner pause the runner or stop one card's job?

## Options

- A: A board key, `runner: paused`, read before each job, plus a `STOP` comment on a card that ends its job and skips the card.
- B: Only by stopping the process (Ctrl-C, or `launchctl` under launchd).
- C: A, set from the app later. Process stop only for now.

## Recommended

A. Both are plain file edits, so they work from the app, a terminal or another session.

## Depends on

- [Q4: One board or many per runner](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/08f2ee0c-c072-4233-b4a2-60841345b416): one board per process
