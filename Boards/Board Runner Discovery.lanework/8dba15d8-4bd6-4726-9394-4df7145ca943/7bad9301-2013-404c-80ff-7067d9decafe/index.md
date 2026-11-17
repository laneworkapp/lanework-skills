---
schema: 1
kind: card
title: "Fact: a headless run loads every lanework skill"
order: 1024
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-10-30T13:48:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
A headless `claude -p` run loads the installed `lanework` plugin. Its init lists every `lanework:` skill, owner-only ones included, and a prompt starting `/lanework:lanework` ran that skill: it replied with the skill's first line. One trivial turn cost $0.14.

## Source

- Test run, Claude Code 2.1.314, 2026-10-30. Report and raw output attached.

## Bears on

- [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74)
- [Q3: What starts a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1237c522-b375-407b-b9f7-13dc79b28cfd)
