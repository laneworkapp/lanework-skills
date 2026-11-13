---
schema: 1
kind: card
title: "Remove this repo's own marketplace.json"
order: 3072
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
modified: {at: 2026-11-13T23:01:36Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
This card deletes the repo's own `.claude-plugin/marketplace.json`, so the central marketplace is the only catalog that lists the plugin.

**Files**
- `skills/`: none touched. Nothing that ships changes.
- `.claude-plugin/marketplace.json`: delete. `plugin.json` stays.
- `CLAUDE.md` (repo root): drop the `marketplace.json` row from the layout table; say the plugin is listed in `laneworkapp/lanework-marketplace`. Reword the `plugin.json` row if it mentions the catalog.
- `tests/smoke.sh` (plugin block, ~line 1455): stop loading `marketplace.json` and drop its two asserts (listed plugin name, no `version`). Keep the `plugin.json` skills-vs-folders assert and `claude plugin validate`.
- `CHANGELOG.md`: no new entry. The November switch notice already tells users what to do; removal changes nothing for anyone who followed it.

**Waits on**: [Point the README at the marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c5b171e1-a2de-4d0e-bdcf-1c9c707c4e2a). Its README and CHANGELOG edits are on `main`, but the latest release is v0.7.0 (October) and `stable` carries no switch notice yet. Cutting that release is the owner's call.

~~**Open call**: how long the grace period runs after the notice ships.~~ **ruled 2026-11-13: A, removal rides the release after the notice release.**

**Risks**
- Users still on the old `lanework` marketplace (this repo's catalog) fail their next `/plugin marketplace update` once `stable` lacks the file. That is the reason for the grace period.
- Removal reaches users only through a release, since `stable` moves only via `scripts/release.sh`.
- The central catalog tracks `ref: stable` in this repo, so it is unaffected. Check it before the release.

**Verified**
- `tests/smoke.sh` passes with the plugin block no longer reading `marketplace.json`.
- `grep -rn marketplace.json` over the repo (excluding `.git` and `Lanework/`) finds nothing.
- `scripts/check.sh` in `lanework-marketplace` still reports `lanework@stable` ok.
- `claude plugin validate` stays clean.

**Done when**: `stable` has no `.claude-plugin/marketplace.json`, `tests/smoke.sh` and the layout table in `CLAUDE.md` no longer mention it, and the central marketplace check passes against the new `stable`.

**Recommendation**: build it after the notice release is out. The change itself is three small edits.
