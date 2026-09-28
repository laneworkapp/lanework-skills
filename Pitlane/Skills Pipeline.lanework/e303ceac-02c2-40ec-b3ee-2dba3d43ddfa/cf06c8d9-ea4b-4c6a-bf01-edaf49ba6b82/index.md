---
schema: 1
kind: card
title: "Skills target agent guide v75: tracker sync"
order: 10240
labels: [{text: lanework-boards, kind: {type: skill, text: Skill}}, {text: pitlane, kind: {type: skill, text: Skill}}, {text: pitwall, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T09:57:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T09:59:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Bring the skills from guide v70 to v75, where the guide gained tracker sync (v71 to v74) and the skills repo's new home (v75).

## Done when

- Every file under `skills/` is read against the v70 to v75 guide delta, and the drift is fixed by pointing at the guide, not restating it.
- No skill leads an agent to write or copy a card's `remote`, its `state` label or a comment's `remote`, or to sign `tracker`.
- An agent on a synced board knows its comments post publicly as the token's user and email the repo's watchers.
- `authority.md` § Versions says `lanework-agent-guide v75`. `lanework-schema` is bumped only if the app's moved.
- `tests/smoke.sh` passes.
