---
schema: 1
kind: card
title: "Fact: a headless session can be resumed by id"
order: 4096
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-10-30T13:48:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
A later `claude -p --resume <session-id>` continues an earlier headless session, from any directory. Resuming does not restore `--settings`, `--add-dir`, `--mcp-config` or `--plugin-dir`: they are passed again. Transcripts are JSONL under `~/.claude/projects/`, kept 30 days, in an internal format that may change.

## Source

- code.claude.com/docs/en/sessions.md, cli-reference.md, read 2026-10-30. Report attached.

## Bears on

- [Q5: Fresh job or resumed session](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/25fe03a3-f47b-4929-934b-e575d7ca7383)
- [Q8: What the owner sees of a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7eb05b54-d522-4a92-a4ea-8371161aced5)
