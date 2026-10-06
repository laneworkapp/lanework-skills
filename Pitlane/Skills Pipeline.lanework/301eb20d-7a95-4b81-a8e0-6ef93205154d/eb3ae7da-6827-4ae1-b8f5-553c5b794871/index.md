---
schema: 1
kind: card
title: "Rename pitwall to watch and pitlane to work"
order: 1024
labels: [{text: pitlane, kind: {type: skill, text: Skill}}, {text: pitwall, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-06T22:35:32Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T22:38:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The racing names ask users to decode a metaphor before they can use the skills, and early users didn't. The two skills take plain verbs that say what they do: `watch` stays up and reacts to a board, `work` files, sweeps and builds on one. They sit beside `lanework` and `discovery`, which already read as plain English.

- **Names**: ~~`watch` for pitwall is settled; the pitlane name is an open call (`work`, `tend`, or keep `pitlane`)~~ **ruled 2026-10-06: `watch` and `work`.** Still beta, so `work` can be renamed again if it doesn't land either.
- **Touches**: `skills/pitwall/` → `skills/watch/` and `skills/pitlane/` → `skills/work/` (`git mv`), each `SKILL.md` `name`, `description` and heading. Every `pitlane/…` and `pitwall/…` citation in all four skills, including `discovery/scripts/file-question.sh`'s path to `lint-ask.sh`. The `/pitwall` command in `watch`, `discovery/SKILL.md` and `README.md`. `.claude-plugin/plugin.json` (`skills` list, `keywords`), `README.md` (skills table, sizes, install lines, the motor-racing section), `CLAUDE.md`, `tests/smoke.sh` and `tests/check-refs.sh`.
- **Out of scope**: the `Pitlane/` folder convention where boards live, and the `Pitlane` wording in `lanework/references/finding.md`. That is a separate decision with a migration cost, to be filed on its own.
- **Board**: the `Skill` label values become `watch` and `work` in this board's instruction sheet and on open cards. Done cards keep the old values as history.
- **Check**: `work`'s description still triggers on "Lanework", "pipeline board", "sweep", "file a card". The base skill's "Not for sweeping or working a board" line names `work`. Prose where "work" is both the skill and the verb stays unambiguous.
- **Version**: major bump at release, per the repo's rule for a renamed skill.
- **Verify**: `tests/smoke.sh` passes, including check-refs. `grep -ri 'pitlane\|pitwall' skills .claude-plugin README.md CLAUDE.md tests` finds only the `Pitlane/` folder convention.
- **Done when**: the above holds and the local `~/.claude/skills` links are renamed.
- **Accepted limitation**: the app's in-board guide names `pitlane` and `pitwall` in its skills paragraph. That fix ships in the app and is tracked outside this board.
