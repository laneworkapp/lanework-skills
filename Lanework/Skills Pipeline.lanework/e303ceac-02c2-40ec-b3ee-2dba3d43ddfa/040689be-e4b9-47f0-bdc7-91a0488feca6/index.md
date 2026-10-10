---
schema: 1
kind: card
title: "Bump the plugin version on every shipped change, with a changelog"
order: 30720
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:21:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T01:51:20Z, by: {name: shaper, kind: agent, model: sonnet}}
---
`plugin.json` has said `0.1.0` through every change in Done. Claude Code uses the plugin's `version` to decide when installed users get an update, so once the plugin is installable ([marketplace.json](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/05809e25-fb9d-42de-b1af-22ec34fc227a)), a version that never moves means users never receive a fix.

- **Touches**: `.claude-plugin/plugin.json`, `CHANGELOG.md` (new), the bump rule in one place (repo `CLAUDE.md` or this board's instruction sheet), maybe `tests/smoke.sh`.
- **Open**: where the rule lives. What major, minor and patch mean for skills (major = boards written by the old skills stop working?). Changelog format. Smoke check that the top CHANGELOG entry matches `plugin.json`?
- **Done when**: the rule is written in one place, the first release under it has a bumped version, and CHANGELOG.md has an entry for it.
