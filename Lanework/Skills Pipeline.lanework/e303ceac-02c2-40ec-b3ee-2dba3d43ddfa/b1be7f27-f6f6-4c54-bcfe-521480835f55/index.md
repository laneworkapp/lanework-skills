---
schema: 1
kind: card
title: "Skills target agent guide v70, with one version stamp"
order: 8192
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
created:  {at: 2026-09-27T22:38:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T20:22:00Z}
---
Keep the target guide version in one place, and bring lanework-boards, pitlane and pitwall up to guide v70.

## Done when

- `skills/lanework-boards/references/authority.md` § Versions holds the only stamp under `skills/`. `README.md` echoes it.
- `tests/smoke.sh` fails on a README mismatch or a second stamp.
- The three skills are read against the v70 guide and the drift is fixed. The stamp says v70.
- README has per-skill file sizes and a note on the names.
