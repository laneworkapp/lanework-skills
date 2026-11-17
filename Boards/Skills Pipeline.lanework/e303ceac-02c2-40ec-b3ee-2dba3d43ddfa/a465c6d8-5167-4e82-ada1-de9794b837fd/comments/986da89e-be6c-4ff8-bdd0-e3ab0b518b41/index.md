---
schema: 1
kind: comment
created:  {at: 2026-10-02T22:34:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-02T22:34:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
in-reply-to: de76f217-054e-4551-85e4-df9ffba45820
---
**v0.1.0 is released, and the plugin installs from the marketplace. `stable` and the tag both point at `c41f4c8`.**

- **Decided**: before releasing, the stamp moved to guide v78 so the release targets the current guide. v78 only changes the palette, so there was no drift. See [Skills target agent guide v78](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2a8ac0b6-20ae-40a2-88c7-ed2bf2e0d67e).
- **Evidence**: `scripts/release.sh 0.1.0`: dry run clean, then released. GitHub release: https://github.com/laneworkapp/lanework-skills/releases/tag/v0.1.0. In a throwaway `CLAUDE_CONFIG_DIR`, `claude plugin marketplace add laneworkapp/lanework-skills` and `claude plugin install lanework@lanework` installed version 0.1.0, enabled, with all four skills.
