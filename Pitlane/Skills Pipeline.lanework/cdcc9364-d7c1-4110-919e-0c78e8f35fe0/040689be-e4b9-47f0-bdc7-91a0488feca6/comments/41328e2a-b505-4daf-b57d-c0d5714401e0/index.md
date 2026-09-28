---
schema: 1
kind: comment
created:  {at: 2026-09-28T00:21:43Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:21:43Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Surfaced comparing with mattpocock/skills, which versions every release and keeps `plugin.json` in step with `package.json`.**

- **Rejected**: their tooling (changesets, `package.json`, `sync-plugin-version.mjs`, a release workflow). It brings npm and Node into a bash-only repo for a four-skill set. A manual bump on the card that ships is enough at this size.
- **Depends on**: [marketplace.json](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/05809e25-fb9d-42de-b1af-22ec34fc227a). Until the plugin is installable, the version has no reader.
