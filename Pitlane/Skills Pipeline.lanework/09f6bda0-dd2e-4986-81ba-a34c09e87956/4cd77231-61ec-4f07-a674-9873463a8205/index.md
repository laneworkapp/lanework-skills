---
schema: 1
kind: card
title: "Smoke fails on main: plugin validate --strict rejects the repo's own CLAUDE.md"
order: 0
labels:
  - text: "repo"
    kind:
      type: "skill"
      text: "Skill"
  - text: "Urgent"
    rank: 0
    color: "#C8283C"
    icon:
      glyph: "exclamationmark.2"
    kind:
      type: "priority"
      text: "Priority"
      icon:
        glyph: "flag"
created:  {at: 2026-10-06T22:41:55Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:42:09Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
`tests/smoke.sh` exits 1 on main at its last step, so every branch's gate is red.

**Reproduce**: `claude plugin validate . --strict` with Claude Code 2.1.292 warns "CLAUDE.md at the plugin root is not loaded as project context", and `--strict` makes the warning an error. The plugin root is the repo root, and `CLAUDE.md` is this repo's own dev guide, so the warning is expected here.

**Why CI missed it**: the runner has no `claude` CLI, so the step is skipped there.

**Files**: `tests/smoke.sh`.

**Verify**: smoke exits 0 on main and prints its success line. A plugin manifest warning other than this one still fails the step.

**Done when**: the step accepts only this one known warning, and smoke passes end to end.
