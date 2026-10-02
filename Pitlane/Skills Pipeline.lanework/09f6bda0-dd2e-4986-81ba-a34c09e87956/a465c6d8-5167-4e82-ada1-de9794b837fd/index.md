---
schema: 1
kind: card
title: "Set up a release workflow: marketplace, versioned releases, CI, stable channel"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-01T16:11:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T16:15:16Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Today every push to main is the release: no tags, no changelog, no CI, and plugin.json has said 0.1.0 since packaging. Users who install the plugin should get tested, versioned releases instead of whatever main holds.

## Change

- `.claude-plugin/marketplace.json`, so the repo installs as a plugin with `/plugin marketplace add laneworkapp/lanework-skills`, with the commands in the README.
- `CHANGELOG.md` at the root, in the house changelog format.
- `scripts/release.sh <version>`: smoke, version bump, release commit, tag, GitHub release with that version's changelog entries, and the `stable` branch moved to the tag. `--dry-run` changes nothing.
- `.github/workflows/smoke.yml`: `tests/smoke.sh` on a macOS runner, on every push and pull request.
- A `stable` branch that plugin installs track, so unreleased work on main never reaches users.

## Done when

- Smoke checks the manifests (valid JSON, matching versions, skills list equal to the folders under `skills/`) and syntax-checks `scripts/`.
- `scripts/release.sh --dry-run` runs clean on the current head.
- The CI workflow passes on GitHub.
