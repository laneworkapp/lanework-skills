---
schema: 1
kind: card
title: "Fact: a headless run denies unapproved tools and keeps going"
order: 2048
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-10-30T13:48:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
In a headless run, a tool call that no allow rule, hook or permission tool approves is denied, and the run continues. Each denial is reported as a `permission_denied` event and listed in the result's `permission_denials`. `dontAsk` mode denies anything that would prompt; reads, allow-listed tools and read-only commands still run. `bypassPermissions` skips all checks.

## Source

- code.claude.com/docs/en/permission-modes.md, headless.md, read 2026-10-30. Report attached.

## Bears on

- Permissions: next round, once [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74) settles
