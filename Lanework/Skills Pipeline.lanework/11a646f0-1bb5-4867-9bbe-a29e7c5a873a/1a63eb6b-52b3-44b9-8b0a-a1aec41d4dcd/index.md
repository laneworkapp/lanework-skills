---
schema: 1
kind: card
title: "Smoke is red: the board's guide moved to v84, the skills are stamped v83"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T10:47:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T10:47:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The Lanework app rewrote this board's guide to `lanework-agent-guide v84`, so smoke's stamp gate fails on main and on every branch.

**Reproduce**: `bash tests/smoke.sh` on main stops at the stamp case: "board guide v84 is newer than the stamp (lanework-agent-guide v83)".

**What v84 changed**: one paragraph, in the lane `group` section. The app's Group By menu now lists None, Modified, Created and Due, then every `single: true` kind in vocabulary order, `priority` and `component` included. Picking a kind writes `{by: label, kind: <type>}`. A lane already written `by: priority` keeps its bytes. The schema stays `lanework-schema v1`.

**Drift**: none found. No skill describes the Group By menu or tells an agent to write `by: priority` or `by: component`.

**Fix**: bump `lanework-agent-guide v83` to `v84` in the repo `CLAUDE.md`, its only stamp, and commit the app's guide rewrite under the board with it.

**Done when**: smoke passes on main, with the stamp case reading v84.
