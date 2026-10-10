---
schema: 1
kind: card
title: "Codex: add agents/openai.yaml per skill, or say Claude Code only"
order: 3072
labels: [{text: repo, kind: {type: skill, text: Skill}}]
waiting: {for: rzen, since: 2026-10-10T01:55:06Z, comment: b7cb952e-6459-4189-a0f4-165c6867f0e7}
created:  {at: 2026-09-28T00:21:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T01:55:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The README says other harnesses that read `SKILL.md` work the same way, but on Codex `discovery` and `watch` can start unprompted: they set `disable-model-invocation: true`, which Codex does not read.

- **Open call**: support Codex or say Claude Code only? **Recommendation: say Claude Code only** (no Codex user on record; Codex support stays partial either way, since `watch` needs Claude Code's Monitor tool and `work`'s tiers name haiku and sonnet).
- **A, Claude Code only (recommended)**
  - **Touches**: `README.md` § Install, the line "other harnesses that read `SKILL.md` files work the same way", rewritten to name Claude Code as the supported harness.
  - **Verify**: read through against the skills' frontmatter (`discovery` and `watch` set `disable-model-invocation: true`); `tests/smoke.sh` passes.
  - **Done when**: `grep -n -i "other harnesses" README.md` finds nothing and the README names Claude Code as the supported harness.
- **B, support Codex**
  - **Touches**: `skills/{lanework,work,watch,discovery,merge}/agents/openai.yaml` (new), `tests/smoke.sh` (a case: the skills with `disable-model-invocation: true` are exactly those whose yaml sets `policy.allow_implicit_invocation: false`), `README.md` § Install, `.claude-plugin/plugin.json` untouched.
  - **Verify**: `tests/smoke.sh` passes; in a scratch copy of the repo, flip one flag and smoke fails naming the skill.
  - **Done when**: five yaml files carry `interface.display_name` and `interface.short_description`, the two user-invoked skills set `allow_implicit_invocation: false`, and the README states Codex support with its two limits.
