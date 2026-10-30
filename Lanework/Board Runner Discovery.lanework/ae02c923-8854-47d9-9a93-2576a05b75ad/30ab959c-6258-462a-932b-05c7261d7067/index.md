---
schema: 1
kind: card
title: "Q7: What counts as success"
order: 7168
labels: [{text: "Round 1", kind: {type: round, text: Round}}]
waiting: {for: rzen, since: 2026-10-30T13:49:18Z, comment: 25255abb-20bf-4bf8-841c-3f134909cbae}
created:  {at: 2026-10-30T13:49:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:18Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
What result counts as the proof of concept working?

## Options

- A: A week unattended on one real board: every owner comment and Shaping move handled, no duplicate job, no job past its turn cap, nothing the owner undoes.
- B: The same bar over a single day.
- C: The owner judges by feel after using it.

## Recommended

A. A week spans enough events and idle time to show runaway or duplicate jobs, and a fixed bar lets the experiment fail.

## Depends on

- [Fact: headless runs cap turns exactly, spend only roughly](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/66603d6f-c6f3-4a8b-967c-7c5f8e0d35a6)
