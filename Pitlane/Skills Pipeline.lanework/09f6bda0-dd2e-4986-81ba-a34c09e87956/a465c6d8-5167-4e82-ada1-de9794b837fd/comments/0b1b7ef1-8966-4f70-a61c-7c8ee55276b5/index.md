---
schema: 1
kind: comment
created:  {at: 2026-10-01T16:11:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T16:11:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**The owner asked in session to build all four parts of the release workflow, so this card starts in Active.**

- **Found**: no tags, releases, changelog or CI. `plugin.json` has been at 0.1.0 since `7f714be`, and the README says the repo installs as a plugin without a marketplace file to install it from.
- **Plan**: the marketplace file, changelog, release script, CI and stable branch as the body lists. The release script and CI are built and checked here. Cutting the first public release is a separate step that needs the owner's go.
