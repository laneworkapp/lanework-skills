---
schema: 1
kind: card
title: "discovery: human-invoked only"
order: 4096
labels:
  - text: "discovery"
    kind:
      type: "skill"
      text: "Skill"
  - text: "pitlane"
    kind:
      type: "skill"
      text: "Skill"
  - text: "lanework"
    kind:
      type: "skill"
      text: "Skill"
created:  {at: 2026-09-27T21:16:25Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T20:22:00Z}
---
Make `discovery` start only when a human types `/discovery`. Set `disable-model-invocation: true` so Claude never calls it on its own and its description never enters Claude's context. The description then only has to tell a human what the skill is in the `/` menu.

## Done when

- `skills/discovery/SKILL.md` frontmatter carries `disable-model-invocation: true`, and its description is one short, human-facing sentence with no trigger phrases or "Not for" clause.
- The "a discovery session (discovery)" exclusions are gone from the `lanework-boards` and `pitlane` descriptions.
- `README.md` says discovery runs only as `/discovery <topic>`, with the command first in the message.
- Verified: the frontmatter parses as YAML, and no other skill tells Claude to invoke discovery.
