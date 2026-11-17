---
schema: 1
kind: card
title: "Repo layout: skills/, pipeline board, CLAUDE.md"
order: 2048
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-27T20:40:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T20:40:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Organize the repo around a development pipeline: the skills move under `skills/`, the pipeline board goes in `Pitlane/`, and a `CLAUDE.md` records the conventions.

## Done when

- Every skill is under `skills/`, and `plugin.json` and the README install commands point there.
- `Pitlane/Skills Pipeline.lanework` is founded with the default pipeline lanes and a `Skill` label kind.
- `CLAUDE.md` covers the layout, how to work on a skill, and git conduct.
