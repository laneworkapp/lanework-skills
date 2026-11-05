---
schema: 1
kind: card
title: "Move the owner's install to lanework-marketplace"
order: 4096
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
modified: {at: 2026-11-05T00:31:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
---
The owner's own Claude Code still installs `lanework` from the old marketplace URL in `~/.claude/settings.json`.

**Change**, on the owner's machine:

```sh
claude plugin marketplace remove lanework
claude plugin marketplace add https://github.com/laneworkapp/lanework-marketplace.git
claude plugin install lanework@lanework
```

Then commit `~/.claude/settings.json` to dotfiles. Stage only the marketplace and plugin lines; that file carries other uncommitted changes.

**Verified**: `claude plugin list` shows `lanework@lanework` at the current stable version, and `extraKnownMarketplaces.lanework` names the new URL.

**Done when**: both of the above hold. Can happen any time: the new marketplace already lists `lanework-skills@stable`.
