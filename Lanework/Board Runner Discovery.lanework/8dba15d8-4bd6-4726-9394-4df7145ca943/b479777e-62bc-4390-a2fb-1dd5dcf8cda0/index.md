---
schema: 1
kind: card
title: "Fact: nothing built in starts a headless run on a file change"
order: 7168
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-10-30T13:48:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
No Claude Code feature starts a headless run when a file changes. Session loops and cron need an open session and expire after 7 days. Desktop scheduled tasks and cloud routines run on a schedule, and routines run in the cloud without local files. Hooks fire on in-session events only.

## Source

- code.claude.com/docs/en/scheduled-tasks.md, hooks.md, agent-sdk/overview.md, read 2026-10-30. Report attached.

## Bears on

- The Topic: the bash loop duplicates nothing built in
