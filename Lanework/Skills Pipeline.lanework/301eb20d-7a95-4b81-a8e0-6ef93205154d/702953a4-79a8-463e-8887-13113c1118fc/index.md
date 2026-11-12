---
schema: 1
kind: card
title: "Move the owner's install to lanework-marketplace"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
modified: {at: 2026-11-12T18:56:26Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
The owner's own Claude Code installs `lanework` from this repo's old catalog URL, and this card points it at `lanework-marketplace` instead.

**Files**: none under `skills/`, and nothing else in this repo. It edits the owner's `~/.claude/settings.json` through the `claude plugin` CLI, then commits that file to the dotfiles repo.

**Change**, on the owner's machine:

```sh
claude plugin marketplace remove lanework
claude plugin marketplace add https://github.com/laneworkapp/lanework-marketplace.git
claude plugin install lanework@lanework
```

Then commit `~/.claude/settings.json` with `dotfiles add`, `commit` and `push`. Stage only the marketplace and plugin lines; that file carries other uncommitted changes.

**Verified**:
- `claude plugin list` shows `lanework@lanework` enabled at the current stable version (0.7.0 at shaping).
- `extraKnownMarketplaces.lanework.source.url` in `~/.claude/settings.json` is the marketplace URL above.
- `dotfiles show --stat HEAD` lists only those settings lines. `tests/smoke.sh` is not involved: no script or skill changes.

**Done when**: both checks above hold and the dotfiles commit is pushed.

**Risks**:
- Removing the marketplace uninstalls its plugins, so the plugin is briefly absent between the remove and the install. Run it between sessions.
- The marketplace and plugin names stay `lanework`, confirmed against the live marketplace file, so existing `lanework@lanework` references keep working.
- Hand-committing settings.json can sweep in unrelated edits; stage with `dotfiles add -p`.

**Recommendation**: do it now. No release is needed, since the new marketplace already serves this repo's `stable` branch. Treat it as an owner chore; an agent should not edit the owner's settings.json unasked.
