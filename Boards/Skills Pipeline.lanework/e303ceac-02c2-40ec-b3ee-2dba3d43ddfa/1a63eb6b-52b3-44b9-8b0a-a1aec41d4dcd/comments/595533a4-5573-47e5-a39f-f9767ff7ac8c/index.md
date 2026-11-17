---
schema: 1
kind: comment
created:  {at: 2026-10-10T10:47:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T10:47:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Filed by the watch, the same shape as the v83 card. It blocks every branch's gate.** Issues is a holding lane, so it waits for the owner.

- **Evidence**: the guide diff is the version line plus 8 lines in the `group` paragraph. `.schema/VERSION` still reads `lanework-schema v1`. A grep of `skills/` for `by: priority`, `by: component` and "Group By" finds nothing.
- **Pattern**: this is the second app guide bump in one day. Each bump turns smoke red until a one-line stamp edit lands. An idea worth filing separately is a way for minor guide bumps to land without a red window.
