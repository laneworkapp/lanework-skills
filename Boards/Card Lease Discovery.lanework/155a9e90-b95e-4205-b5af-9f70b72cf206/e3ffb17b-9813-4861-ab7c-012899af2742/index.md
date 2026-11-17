---
schema: 1
kind: card
title: "A subagent shares its parent session's id"
order: 5120
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-11-14T13:45:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: F5
---
A subagent started with the Agent tool runs its shell with the same `CLAUDE_CODE_SESSION_ID` and `CLAUDE_PID` as the session that started it, and its shell's parent pid is that session's pid. A session and all of its subagents read as one holder by the session id alone.

Not checked: whether a headless `claude -p` job sets its own id.

## Source

- `env | grep -E '^CLAUDE_(CODE_SESSION_ID|PID)='` and `echo $PPID`, in this session and in a Haiku subagent it started, Claude Code, read 2026-11-14

## Bears on

- [Q1](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb): what identifies a lease's holder
