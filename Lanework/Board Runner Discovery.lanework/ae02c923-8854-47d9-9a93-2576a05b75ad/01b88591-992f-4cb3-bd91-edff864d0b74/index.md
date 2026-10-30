---
schema: 1
kind: card
title: "Q1: Phase 1 scope"
order: 1024
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T13:49:16Z, comment: 21c455a4-6ee2-42bf-8c82-18425e86ca14}
created:  {at: 2026-10-30T13:49:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Which work does the runner take on in phase 1?

## Options

- A: Board-side only: shape cards in Shaping, answer owner comments, fold rulings.
- B: Board-side plus builds of Approved cards, with worktree, fixer and reviewer.
- C: Everything the agent lanes allow from day one, builds gated on free memory.

## Recommended

A. Board-side jobs are short and touch only Markdown, so they test continuous running and flat context without the worktree, memory and trust risks a build adds.

## Depends on

- [Fact: a headless run loads every lanework skill](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7bad9301-2013-404c-80ff-7067d9decafe)
