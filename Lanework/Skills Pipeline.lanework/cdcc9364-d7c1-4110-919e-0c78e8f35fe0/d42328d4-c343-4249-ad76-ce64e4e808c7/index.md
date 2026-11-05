---
schema: 1
kind: card
title: "Remove this repo's own marketplace.json"
order: 3072
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
modified: {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
---
Once the central marketplace is the documented install path, this repo's `.claude-plugin/marketplace.json` is a second, stale catalog.

**Change**
- Delete `.claude-plugin/marketplace.json`. Keep `plugin.json`.
- `CLAUDE.md` layout table: drop the `marketplace.json` row. Point to `laneworkapp/lanework-marketplace` as where the plugin is listed.

**Waits on**: [Point the README at the marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c5b171e1-a2de-4d0e-bdcf-1c9c707c4e2a) shipped in a release, with a grace period for existing users to switch.

**Verified**: smoke passes. `scripts/check.sh` in `lanework-marketplace` still finds `lanework-skills@stable`.

**Done when**: `stable` has no `marketplace.json`, and the only install path anywhere is the central marketplace.
