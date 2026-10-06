---
schema: 1
kind: card
title: "Fix found-board.sh dropping lane bodies when collapsed is empty"
order: 3072
labels:
  - text: "lanework"
    kind:
      type: "skill"
      text: "Skill"
  - text: "High"
    rank: 1
    color: "#E07A1F"
    icon:
      glyph: "exclamationmark"
    kind:
      type: "priority"
      text: "Priority"
      icon:
        glyph: "flag"
created:  {at: 2026-10-06T22:24:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:32:11Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
`found-board.sh` founded every lane with an empty body unless its `collapsed` cell was filled, so pipeline boards came out with no lane policy at all.

**Reproduce**: found a pipeline board from `templates/pipeline-lanes.md`. Every lane's body is blank. In the design loop only "Dead ends" (`collapsed: yes`) keeps its body.

**Cause**: rows were split with `IFS=$'\t'`. Tab is IFS whitespace, so the empty `collapsed` field merged away and the body shifted into `COLLAPSED`.

**Files**: `skills/lanework/scripts/found-board.sh`, `tests/smoke.sh`.

**Verify**: smoke asserts a pipeline lane with an empty `collapsed` keeps its body and has no `collapsed:` key, and the design loop's "Dead ends" lane has `collapsed: true` and its body. The new check fails on the old script.

**Done when**: rows split on a non-whitespace separator, and smoke passes with both checks.
