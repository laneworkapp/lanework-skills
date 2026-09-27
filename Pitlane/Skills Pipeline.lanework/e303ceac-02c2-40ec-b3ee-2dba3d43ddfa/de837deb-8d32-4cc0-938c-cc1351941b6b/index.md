---
schema: 1
kind: card
title: "pitlane: an explicit build team, adversarial review when warranted"
order: 7168
labels: [{text: pitlane, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-27T22:10:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T22:10:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Describe the lead/fixer/reviewer team in one place, and make the reviewer adversarial when the risk warrants it, without endless review rounds.

## Done when

- `skills/pitlane/references/team.md` holds the roster, channels, review stance and review bounds. `SKILL.md` links it.
- Adversarial stance is set automatically from named triggers. It reads the diff before the reports and runs its own fail-before in a scratch worktree.
- Only a finding with a failure scenario blocks. Re-review is scoped, and there are at most two REQUEST-CHANGES rounds.
- The fixer records FAIL-BEFORE in Phase-1. The verdict template carries STANCE, BLOCKING and NOTES.
- `tests/smoke.sh` passes.
