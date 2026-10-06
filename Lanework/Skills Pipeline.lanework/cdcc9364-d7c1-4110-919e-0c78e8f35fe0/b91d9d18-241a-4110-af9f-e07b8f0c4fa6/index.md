---
schema: 1
kind: card
title: "Codex: add agents/openai.yaml per skill, or say Claude Code only"
order: 5120
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:21:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:21:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The README says other harnesses that read `SKILL.md` work the same way. On Codex they don't: `discovery` and `pitwall` rely on `disable-model-invocation: true`, and Codex reads its own flag instead, so it can start them unprompted. Pick one route:

- **Support**: `skills/<name>/agents/openai.yaml` per skill, with `interface.display_name` and `interface.short_description` for the picker, plus `policy.allow_implicit_invocation: false` on the two user-invoked skills. Smoke checks that the two flags agree.
- **Disclaim**: the README names Claude Code as the supported harness.

- **Open**: is there a Codex audience? `pitwall` needs Claude Code's Monitor tool, and pitlane's tiers name haiku and sonnet, so Codex support is partial either way.
- **Done when**: the README's harness claim is true.
