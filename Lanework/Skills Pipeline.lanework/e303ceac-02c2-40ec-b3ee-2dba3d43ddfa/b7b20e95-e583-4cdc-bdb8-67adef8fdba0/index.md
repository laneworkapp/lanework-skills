---
schema: 1
kind: card
title: "Install over HTTPS: the GitHub shorthand clones over SSH"
order: 24576
labels: [{text: "repo", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-10-07T13:11:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-07T13:12:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Users without an SSH key for github.com couldn't install the plugin, because a GitHub `owner/repo` source clones over SSH by default.

**Cause**: `marketplace.json` used a `github` plugin source, and the README's `/plugin marketplace add laneworkapp/lanework-skills` used the same shorthand. Claude Code's plugin docs say the shorthand clones over SSH unless `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` is set.

**Fix**: a `url` plugin source with `https://github.com/laneworkapp/lanework-skills.git` and `ref: stable`, and the README's add command takes the HTTPS URL.

**Done when**: an anonymous HTTPS clone works, smoke passes, and the fix ships.
