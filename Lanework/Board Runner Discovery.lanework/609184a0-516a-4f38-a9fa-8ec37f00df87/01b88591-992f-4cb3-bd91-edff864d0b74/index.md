---
schema: 1
kind: card
title: "Q1: Phase 1 scope"
order: 1024
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
created:  {at: 2026-10-30T13:49:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T14:08:03Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
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

## Ruling

**2026-10-30**: B, over the recommended A. "B is the right choice for us but work should be performed by `/lanework:work`"
ADR: [ADR: Runner jobs do their work through the work skill](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/94e4cee5-a0f5-4793-8707-f5ac0681785c)
PDR: [PDR: Phase 1 runs board-side jobs and builds](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7ffd2bf2-15aa-4968-88b1-66bccbd86db5)
