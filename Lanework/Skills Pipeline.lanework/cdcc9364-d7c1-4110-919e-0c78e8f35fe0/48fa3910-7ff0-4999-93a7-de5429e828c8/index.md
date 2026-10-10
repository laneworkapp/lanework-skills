---
schema: 1
kind: card
title: "watch: re-read the skills when a release lands mid-watch"
order: 4096
labels: [{text: watch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T03:08:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T03:08:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
A watch reads its skill files once, at arming, so a fix released while it runs never reaches it until it is re-armed.

- **Seen**: the Lanework Pipeline watch held a Proposed → Approved move as a gate decision after [0d374675](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0d374675-f23c-4959-95dc-07e10f99d345) had shipped in v0.3.0, because it was still following the text it read at arming.
- **Idea**: `watch/references/arming.md` records the skills' version (`.claude-plugin/plugin.json` beside the skills, or the plugin cache path). On each wake, a changed version → re-read `work/SKILL.md`, the watch references and `lanework/references/board-kinds.md` before acting, then report the new version.
- **Open for shaping**: where the version is read for a symlinked install vs a plugin install, and whether `watch-boards.sh` emits the change as an event of its own.
