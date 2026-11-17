---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:53:06Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:53:06Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**START, posted after the first edits by mistake: the fixer builds in the `guide-v118-anyone` worktree.**

- **Stamp**: v118. The version gate for the anyone-address stays "117 or later", in `ask_handle` only (no skill file names a guide version).
- **Taken**: the `in-reply-to` clause in `lanework/references/writes.md`, and field-evidence item 1 (writing.md says outright the handle never comes from the "answers to" line, and agents never act on the anyone handle).
- **Declined**: field-evidence item 2, the lint warning for a v117+ ask naming the machine's handle. No way to tell a question that is one person's from a default, so the lint would flag the gates the board's sheet names.
- **Not touched**: `skills/dispatch/`, per the retirement note.
