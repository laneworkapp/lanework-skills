---
schema: 1
kind: card
title: "Pipeline boards found a Tasks lane by default"
order: 13312
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: pitlane, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-01T10:37:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T10:37:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Add `Tasks` to the default pipeline lane set, as the owner's side entrance for small, clear chores. A card the owner files in Tasks is already approved and is built straight through Active. Agents file the chores they find in Ideas, never in Tasks.

## Done when

- `lanework/templates/pipeline-lanes.md` founds Tasks at order 1792, between Issues and Shaping, with its policy in the lane body.
- The flow text in `lanework/templates/pipeline-index.md`, `lanework/references/board-kinds.md`, `pitlane/SKILL.md` and `README.md` names Tasks. `pitlane/references/sweep.md` farms Tasks cards like Approved ones.
- Smoke expects 8 pipeline lanes and passes.
