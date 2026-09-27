---
schema: 1
kind: card
title: "Rename grill-me to discovery, with PDRs"
order: 1024
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-27T20:40:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T20:40:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Rename `grill-me` to `discovery` and reframe it as a guided examination of every corner of a project's problem and domain space. It produces a discovery board, a glossary, and ADR and PDR records.

## Done when

- The skill lives at `skills/discovery/`, and boards are named `<Topic> Discovery.lanework`.
- A corners table (problem, people, domain, scope, behavior, constraints, architecture, integrations, data, risks, success) drives the discovery map.
- `references/docs.md` defines PDRs (`docs/pdr/`) beside ADRs (`docs/adr/`), with a shared format, bar and superseding rule.
- Existing `<Topic> Grill.lanework` boards resume unchanged, and "grill me" still triggers the skill.
