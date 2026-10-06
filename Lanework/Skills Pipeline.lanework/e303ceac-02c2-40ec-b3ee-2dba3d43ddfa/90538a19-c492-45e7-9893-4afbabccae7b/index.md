---
schema: 1
kind: card
title: "README sizes count only the Markdown an agent reads"
order: 9216
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:30:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:30:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The README's size tables count only what can enter an agent's context: `SKILL.md`, references, and the templates an agent fills in. Scripts, and the templates only a script reads, are left out.

## Done when

- The per-skill tables in `README.md` § Sizes list no scripts and no script-only templates, and each total matches the summary table.
- The note under the summary table says what is counted and what is left out.
