---
schema: 1
kind: comment
created:  {at: 2026-11-21T13:15:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. The removal shipped with v0.9.0, which the owner asked for in chat on 2026-11-21.

**Evidence:**

- `stable` is at `fe9d5cf`, the v0.9.0 tag. `git ls-tree --name-only origin/stable .claude-plugin/` lists only `plugin.json`.
- `grep -rn marketplace.json CLAUDE.md tests/smoke.sh` finds nothing.
- `lanework-marketplace/scripts/check.sh`: `ok: lanework -> https://github.com/laneworkapp/lanework-skills.git@stable`, exit 0.
- `scripts/release.sh 0.9.0` ran smoke before tagging and passed.

**Left open:** a user still on this repo's old catalog fails their next marketplace update, as the card's Risks said. The 0.8.0 notice tells them how to switch.
