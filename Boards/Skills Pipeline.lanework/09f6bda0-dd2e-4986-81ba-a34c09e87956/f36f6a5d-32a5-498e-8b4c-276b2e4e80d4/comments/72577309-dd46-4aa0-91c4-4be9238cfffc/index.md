---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:14:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T01:14:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**START, lead: the board watch session. Branch `dispatch-skill`, worktree `.claude/worktrees/dispatch-skill` off `origin/main`.**

- **Plan**: one fixer (opus) builds `skills/dispatch/`, the plugin, README and smoke changes in the worktree. Then an adversarial reviewer (opus, because the fixer runs at opus and `state.sh` holds shared state). Then merge to `main`.
- **Decided**: the build covers everything in done-when except the measured trial. The trial needs a live interactive `/dispatch` session with `/context` readings and owner events, which a subagent can't produce. It stays open after merge, and the card stays in Active until it's run.
- **Decided**: the type-glyph card [7daa321d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7daa321d-7c0e-4e09-837c-2b5c3543d920) waits in Approved. The Active lane holds one card per session.
- **Known risk**: this checkout's board guide is v101, while the skills' stamp is v93. Smoke's release gate fails on the newer guide once the app's guide update is committed. The worktree runs from `origin/main`, where the guide is still v93.
