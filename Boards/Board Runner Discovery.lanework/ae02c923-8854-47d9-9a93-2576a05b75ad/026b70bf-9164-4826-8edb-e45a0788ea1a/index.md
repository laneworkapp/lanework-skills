---
schema: 1
kind: card
title: "Q17: How the runner starts"
order: 9216
labels: [{text: "Round 2", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T15:30:21Z, comment: 36f5a5b2-eb52-46ef-8d2e-3fbf6332538d}
created:  {at: 2026-10-30T15:30:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:30:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
How is the runner started in phase 1?

## Options

- A: From a terminal only. The script takes a board path and streams to that terminal.
- B: A, plus an installer that writes a launchd agent per board.
- C: launchd only.

## Recommended

A. The output streams to a terminal by ruling, and launchd can follow once the owner has watched it run.

## Depends on

- [Q4: One board or many per runner](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/08f2ee0c-c072-4233-b4a2-60841345b416): one board per process
- [Q8: What the owner sees of a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7eb05b54-d522-4a92-a4ea-8371161aced5): jobs stream live to the terminal
- [Fact: launchd jobs need a token in the settings env block](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/f711fd08-c333-43fd-9c34-4c972fdf8267)
