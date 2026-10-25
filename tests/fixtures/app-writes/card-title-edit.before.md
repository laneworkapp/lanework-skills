---
schema: 1
kind: card
title: "file-question.sh drops a backslash from titles, and stamps model: unknown"
order: 2048
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T01:09:29Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T01:09:29Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
A backslash in a question title gets mangled when `file-question.sh` writes the card. `file-record.sh` escapes the same input correctly.

**Reproduce**: on a scratch discovery board, `file-question.sh` with a title carrying `C:\path`. The written title loses or mangles the backslash, and the next record's link text shows it.
**Also**: without `--model`, both scripts stamp `model: unknown` from an unset `CLAUDE_MODEL`.
**Fix**: escape titles the way `file-record.sh` does (backslash, then quote, newlines to a space). Decide what the model default should be.
**Done when**: a smoke title with a backslash round-trips through `file-question.sh`, and the board validates.
