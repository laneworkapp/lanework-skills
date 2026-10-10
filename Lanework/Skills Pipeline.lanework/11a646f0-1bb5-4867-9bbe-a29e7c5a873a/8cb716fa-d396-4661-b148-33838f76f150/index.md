---
schema: 1
kind: card
title: "Smoke is red: the board's guide moved to v83, the skills are stamped v82"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T02:46:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T02:46:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The Lanework app rewrote this board's guide to `lanework-agent-guide v83`, so smoke's stamp gate fails on main and on every branch.

**Reproduce**: `bash tests/smoke.sh` on main stops after `ok 63` with "board guide v83 is newer than the stamp (lanework-agent-guide v82): read every skill against it, fix the drift, then bump the stamp in CLAUDE.md".

**What v83 changed**: one feature. A lane's `group` gains `by: label` with a third subkey `kind`, which sections cards on any one label kind. The schema stays `lanework-schema v1`.

**Drift**: none found. No skill lists the `group` `by` values. The one mention, `lanework/references/board-kinds.md:25` ("`group` by `modified`, descending"), is still correct.

**Fix**: bump `lanework-agent-guide v82` to `v83` in the repo `CLAUDE.md`, its only stamp. One line.

**Done when**: smoke passes on main, with the stamp case reading v83.
