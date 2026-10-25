---
schema: 1
kind: card
title: "Filing scripts: union the lane's card-defaults labels into new cards"
order: 1024
labels: [{text: plan, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T11:22:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T11:22:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
`plan/scripts/file-ticket.sh`, `discovery/scripts/file-question.sh` and `discovery/scripts/file-record.sh` file cards straight onto disk without unioning the destination lane's `card-defaults.labels`, as the guide requires (§ Frontmatter, `card-defaults`).
