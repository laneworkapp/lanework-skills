---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:52:06Z, by: {name: shaper, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:52:06Z, by: {name: shaper, kind: agent, model: sonnet}}
---
**Open call: support Codex with `agents/openai.yaml` per skill, or say Claude Code only. Recommendation: say Claude Code only.**

- **Problem**: `README.md` § Install says other harnesses that read `SKILL.md` work the same way. On Codex `discovery` and `watch` can start unprompted: they set `disable-model-invocation: true` (Claude Code's flag), and Codex reads `policy.allow_implicit_invocation` from `agents/openai.yaml` instead. No skill folder has an `agents/` directory today.
- **A, say Claude Code only**: one README edit, no new files. Costs nothing to keep true.
- **B, support Codex**: five `skills/<name>/agents/openai.yaml` files (`lanework`, `work`, `watch`, `discovery`, `merge`) with `interface.display_name` and `interface.short_description`, `policy.allow_implicit_invocation: false` on the two user-invoked skills, and a smoke case that the two flags agree. Support stays partial: `watch` needs Claude Code's Monitor tool and `work`'s tiers name haiku and sonnet.
- **Why A**: no Codex user is on record, and B adds a second flag every new skill must keep in step. The leaning from the filing comment stands.
- **Reversible**: A can become B later when a Codex user turns up; B's files are then added with their smoke case.
