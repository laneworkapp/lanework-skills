---
schema: 1
kind: comment
created:  {at: 2026-09-28T00:21:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:21:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Surfaced comparing this repo with mattpocock/skills, which ships `marketplace.json` beside `plugin.json` as a direct-install route.**

- **Why**: a plugin install keeps the four skills side by side, which every cross-skill citation and the `lib.sh` relative path depend on.
- **Rejected**: a separate canonical install-wording file (theirs is `.agents/install-block.md`). The README is our only consumer.
- **Later**: a listing in the official marketplace, once this route works.
