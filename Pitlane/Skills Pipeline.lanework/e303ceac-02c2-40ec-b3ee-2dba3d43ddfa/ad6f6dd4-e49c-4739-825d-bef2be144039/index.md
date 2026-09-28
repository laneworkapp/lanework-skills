---
schema: 1
kind: card
title: "Rename lanework-boards to lanework"
order: 11264
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T10:14:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T10:20:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The base skill takes the product's name, so it reads as "start here" and matches the plugin name. Its siblings read as specialisations under it.

- **Touches**: `skills/lanework-boards/` → `skills/lanework/` (`git mv`) and its `SKILL.md` `name`. Every citation and `lib.sh` path in the other skills. `.claude-plugin/plugin.json`, `README.md` (skills table, sizes, install lines), `CLAUDE.md`, `tests/smoke.sh`.
- **Board**: the `Skill` label value becomes `lanework` in this board's instruction sheet and on open cards. Done cards keep the old value as history.
- **Check**: pitlane's "use whenever the user mentions Lanework" still routes sweeping and working to pitlane. The base skill's "Not for sweeping or working a board (pitlane)" line holds.
- **Verify**: `tests/smoke.sh` passes, including check-refs. `grep -r lanework-boards` finds nothing outside the board's history and the app's guide.
- **Done when**: the above holds and the local `~/.claude/skills` link is renamed.
- **Accepted limitation**: the app's in-board guide names `lanework-boards` in its skills paragraph. That fix ships in the app, in the same release, and is tracked outside this board.
