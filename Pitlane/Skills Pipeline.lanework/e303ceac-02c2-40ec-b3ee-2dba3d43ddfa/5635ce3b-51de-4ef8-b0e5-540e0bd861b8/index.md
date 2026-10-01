---
schema: 1
kind: card
title: "DRY, telegraphic restructure of lanework-boards, pitlane, pitwall"
order: 5120
labels:
  - text: "pitlane"
    kind:
      type: "skill"
      text: "Skill"
  - text: "pitwall"
    kind:
      type: "skill"
      text: "Skill"
  - text: "repo"
    kind:
      type: "skill"
      text: "Skill"
  - text: "lanework"
    kind:
      type: "skill"
      text: "Skill"
created:  {at: 2026-09-27T21:18:24Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T20:22:00Z}
---
Apply the discovery treatment to the other three skills: telegraphic agent-facing text, and one topic per file, across skills as well as within them.

## Done when

- Each `SKILL.md` is a hub that links one file per topic.
- Board fundamentals (format, authority, finding, reading, writes, founding, kinds) live once, in `lanework-boards`. Prose rules live once, in `pitlane/references/writing.md`.
- One founding script (`lanework-boards/scripts/found-board.sh`) and one helper library (`lib.sh`) serve every skill. Lane sets live in templates the script reads.
- `tests/smoke.sh` and `tests/check-refs.sh` pass.
