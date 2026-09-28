---
schema: 1
kind: card
title: "Make the plugin installable: marketplace.json and a real install command"
order: 2048
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:21:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:21:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The README says the repo installs as one plugin but gives no command, and without `.claude-plugin/marketplace.json` there is no `/plugin` route to it. Add the manifest so the repo is its own one-plugin marketplace, and put the real commands in the README.

- **Touches**: `.claude-plugin/marketplace.json` (new), README § Install, `tests/smoke.sh`.
- **Verify**: `claude plugin validate . --strict` passes. From a clean `~/.claude`, `/plugin marketplace add laneworkapp/lanework-skills` then `/plugin install lanework@<marketplace>` loads all four skills, and a script sourcing `../../lanework-boards/scripts/lib.sh` runs from the plugin cache.
- **Open**: plugin install as the documented route with symlinks as the fallback, or both? Smoke runs validate only when `claude` is on PATH? A dev `scripts/link-skills.sh` in place of the README's four `ln -s` lines?
- **Done when**: the README's install command works on a clean machine, and smoke validates the manifests.
