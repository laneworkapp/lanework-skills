---
schema: 1
kind: card
title: "Skills target agent guide v77: tracker engine off in the release"
order: 12288
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: pitlane, kind: {type: skill, text: Skill}}, {text: pitwall, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-29T16:14:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-29T16:14:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Bring the skills from guide v75 to v77. v76 only renamed `lanework-boards` to `lanework`, which is already shipped. v77 builds the tracker engine behind a flag that is off in the release, and its guide then reserves every tracker key.

## Done when

- `lanework/references/writes.md` § Tracker boards splits on what the board's guide says: engine off → every tracker key reserved, never written, edited or copied. Engine on → the v75 rules.
- pitlane's and pitwall's tracker lines apply only with the engine on.
- The stamp in `lanework/references/authority.md` says v77. Smoke passes.
