---
schema: 1
kind: card
title: "README: name Claude Code as the supported harness"
order: 3072
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:21:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T01:58:30Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
The README says other harnesses that read `SKILL.md` work the same way, but on Codex `discovery` and `watch` can start unprompted: they set `disable-model-invocation: true`, which Codex does not read.

- ~~**Open call**: support Codex or say Claude Code only?~~ **ruled 2026-10-10: A, Claude Code only. One README edit.**
- **Touches**: `README.md` § Install, the line "other harnesses that read `SKILL.md` files work the same way", rewritten to name Claude Code as the supported harness.
- **Verify**: read through against the skills' frontmatter (`discovery` and `watch` set `disable-model-invocation: true`). `tests/smoke.sh` passes.
- **Done when**: `grep -n -i "other harnesses" README.md` finds nothing, and the README names Claude Code as the supported harness.
- **Out of scope**: Codex metadata and harness-neutral `work` wording. The compatibility inventory in the thread stays as the starting point if Codex support is wanted later.
