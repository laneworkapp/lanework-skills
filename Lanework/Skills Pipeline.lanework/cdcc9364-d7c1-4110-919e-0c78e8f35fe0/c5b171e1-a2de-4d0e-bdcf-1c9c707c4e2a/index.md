---
schema: 1
kind: card
title: "Point the README install at lanework-marketplace"
order: 2048
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
modified: {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
---
Plugin users should add the new central marketplace, `laneworkapp/lanework-marketplace`, instead of this repo's own `.claude-plugin/marketplace.json`.

**Change**
- `README.md` § install: `/plugin marketplace add https://github.com/laneworkapp/lanework-marketplace.git`. `/plugin install lanework@lanework` stays.
- `CHANGELOG.md`: an entry for existing users. Remove the old marketplace (`/plugin marketplace remove lanework`), then add the new one. Both register as `lanework`, so they can't be added side by side.
- Ships in the next release.

**Verified**: `check-sizes.sh` and smoke pass. A fresh `marketplace add` of the new URL installs `lanework@lanework` from `stable`.

**Done when**: the README on `stable` names only the new URL, and the release notes carry the switch-over steps.

**Then**: [Drop the plugin repo's own marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7).
