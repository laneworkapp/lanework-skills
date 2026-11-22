---
schema: 1
kind: comment
created:  {at: 2026-11-22T22:38:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T22:38:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: one pick rule in `lanework/references/reading.md`, priority shown by the board reader, and the watch's "top of Approved" changed to follow it.**

- **Bigger than filed**: the watch picks by `order` alone, in `watch/scripts/arm-pass.sh`, so this is a script change and five prose edits, not prose only.
- **Correction to the filing**: there is no `skills/dispatch/` in this repo. The picks are in the watch script and the build lead's ordering.
- **Rule**: build-blockers, then lowest priority rank, then lane order. No priority sorts last. Within one lane only.
- **Consequence to review**: priority beats manual drag order in Approved. A dragged card is passed over by a higher-priority card below it.
- **Reader**: `priority: High (1)` appended after the card id. Cards with no priority print exactly as today.
- **Out of scope**: plan and discovery boards.
- **Open calls**: none. The two listed at filing are stated as decisions in the body.
- **Release**: minor (new behavior).
