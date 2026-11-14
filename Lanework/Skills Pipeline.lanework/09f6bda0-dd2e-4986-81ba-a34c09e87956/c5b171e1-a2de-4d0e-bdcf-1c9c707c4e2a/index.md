---
schema: 1
kind: card
title: "Point the README install at lanework-marketplace"
order: 4096
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
modified: {at: 2026-11-14T03:59:25Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
waiting: {for: anyone, since: 2026-11-14T03:59:25Z, comment: e7c4a842-4a44-47a0-acb1-ade05ef3ffed}
---
Plugin users should add the new central marketplace, `laneworkapp/lanework-marketplace`, instead of this repo's own `.claude-plugin/marketplace.json`.

**Scope**: two files, `README.md` and `CHANGELOG.md`. No file under `skills/` changes.

**Change**
- `README.md:159`, § Install: `/plugin marketplace add https://github.com/laneworkapp/lanework-marketplace.git`. Line 160 (`/plugin install lanework@lanework`) and line 163 stay: the new marketplace is also named `lanework` and lists `lanework` from this repo's `stable` branch (read on `main` of `lanework-marketplace` 2026-11-12). The manual-install block at line 168 clones this repo, so its URL stays.
- `CHANGELOG.md`: a new `**November 2026**` heading above `**October 2026**` (line 1), one single-sentence entry, no bullets: existing plugin users run `/plugin marketplace remove lanework`, then `/plugin marketplace add https://github.com/laneworkapp/lanework-marketplace.git`, then `/plugin install lanework@lanework`, because both marketplaces register as `lanework` and can't sit side by side. The `Version 0.8.0: ` line that `scripts/release.sh` requires (`release.sh:26`) is written once for the whole release, by whichever 0.8.0 card builds first. This entry is not it.
- Not touched: `.claude-plugin/marketplace.json`, `CLAUDE.md:11`, `tests/smoke.sh:1106-1109`. They go with [Drop the plugin repo's own marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7), which must wait until users have had a release to switch, because anyone still on the old marketplace reads that file from `main`.

**Risks**
- Removing the old marketplace may also uninstall the plugin, hence the third command in the entry. The build checks this in the verification below and words the entry to match.
- README on `main` names the new URL before `stable` does. Nothing breaks: the plugin source in both marketplaces is the `stable` branch.

**Verified**
- `tests/check-sizes.sh` and `tests/smoke.sh` pass (the edit is outside the counted files).
- In a throwaway `CLAUDE_CONFIG_DIR` outside the repo, `claude plugin marketplace add https://github.com/laneworkapp/lanework-marketplace.git` then `claude plugin install lanework@lanework` installs from `stable`. In a second throwaway dir, add the old marketplace, install, remove it, add the new one: output quoted in the closing comment, entry wording matched to it.
- `scripts/release.sh <version> --dry-run` prints the entry in the release notes.

**Done when**: `grep -rn "lanework-skills.git" README.md` finds only the manual-install clone; the README on `stable` names only the new marketplace URL; the release notes carry the three switch-over commands.

**Recommendation**: build as above, in 0.8.0. Deferred: removing the old marketplace file (the card below).

**Then**: [Drop the plugin repo's own marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7).
