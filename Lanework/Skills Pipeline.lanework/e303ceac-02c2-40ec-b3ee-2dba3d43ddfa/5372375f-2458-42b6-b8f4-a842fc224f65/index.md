---
schema: 1
kind: card
title: "Teach that priority and component are root keys, never labels entries"
order: 17408
labels:
  - text: "lanework"
    kind:
      type: "skill"
      text: "Skill"
  - text: "Medium"
    rank: 2
    kind:
      type: "priority"
      text: "Priority"
      icon:
        glyph: "flag"
created:  {at: 2026-10-02T23:11:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "Palette Labels"}}
modified: {at: 2026-10-02T23:11:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "Palette Labels"}}
---
Agents wrote a card's priority as a `labels` entry with `kind: {type: "priority"}` instead of the root `priority:` key, and nothing in the skills said where it goes.

**Reproduce**: three Issue cards on the app's Lanework Pipeline board (filed 2026-09-29/30 by an opus session) carried `{text: "Low", rank: 3, kind: {type: "priority"}}` beside a custom `type` entry. The app does not read that entry: the face draws it as a stray chip, and grouping and filters skip it.

**Files**: `skills/lanework/references/writes.md` § Every write.

**Verify**: read through against `lanework-agent-guide v78` § Frontmatter (`priority`, `component`, built-in kinds never stamped). `tests/smoke.sh` green.

**Done when**: `writes.md` states the root-key rule with an example, and smoke passes.
