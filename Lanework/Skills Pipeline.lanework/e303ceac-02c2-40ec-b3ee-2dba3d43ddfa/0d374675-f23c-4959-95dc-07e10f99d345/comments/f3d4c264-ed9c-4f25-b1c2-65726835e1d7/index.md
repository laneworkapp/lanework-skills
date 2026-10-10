---
schema: 1
kind: comment
created:  {at: 2026-10-10T03:07:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T03:07:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
**Second sighting after the merge: the Lanework Pipeline watch held a Proposed → Approved move as a gate decision, going by the pre-fix rule it read at arming.**

- **Cause**: a watch reads the skill files once, at arming. `~/.claude/skills/watch` is a symlink to main, so the files on disk were current while the session's copy was not.
- **Resolution**: that session was told to re-read events.md, arming.md, responding.md and board-kinds.md and build the approved card. No skill change is needed.
- **Accepted limitation**: a skill fix reaches a running watch only when it is re-armed or re-reads its files.
