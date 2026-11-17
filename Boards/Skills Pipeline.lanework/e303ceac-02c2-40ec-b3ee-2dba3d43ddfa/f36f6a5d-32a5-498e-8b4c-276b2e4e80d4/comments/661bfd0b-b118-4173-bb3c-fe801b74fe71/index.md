---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:38:16Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed as withdrawn 2026-11-17: the dispatch skill is retired, so the trial this card waited on will not run.**

- **By**: [Retire the dispatch skill](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/ee07c8d2-6fa8-41ac-b06a-ceb5f3045fd0), merged to main as `a0d281c`. The owner ruled there (B1) that this card closes when that one lands.
- **What shipped and is now removed**: `skills/dispatch/`, in 0.7.0 and 0.8.0. It goes with the next release, 0.9.0.
- **What survives**: the arming sweep, `arm-pass.sh`, now at `skills/watch/scripts/`, and the rule that a watch answers owner comments left while no watch ran.
- **Done-when**: not met. The live trial ran only its arming half, on 2026-11-16; `/clear`, a restart and a long session never ran.
