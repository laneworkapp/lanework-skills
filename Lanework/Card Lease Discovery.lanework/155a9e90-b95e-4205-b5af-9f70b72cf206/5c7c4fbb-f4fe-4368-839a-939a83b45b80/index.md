---
schema: 1
kind: card
title: "A Claude Code session carries a unique id in its environment"
order: 4096
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: F4
---
A Claude Code session's shell carries `CLAUDE_CODE_SESSION_ID`, a UUID, and `CLAUDE_PID`. A stamp's `by` takes any subkey, and the skills' scripts already accept `--session`. Today that subkey holds a free label such as "board watch", which two sessions can share, and most stamps carry none.

Not checked: whether a subagent's shell sees its parent's id, and whether a headless `claude -p` job sets the same variable. [Fact: a headless session can be resumed by id](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1a99a2ff-d429-4f9d-aa47-3616cbefb7f6) shows a headless job has a session id of some kind.

## Source

- `env` in a Claude Code 2.1.321 session, read 2026-11-14
- `skills/lanework/scripts/lib.sh`, `by_of`, and the guide's § Stamping your work, read 2026-11-14

## Bears on

- [Q1](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb): what identifies a lease's holder
