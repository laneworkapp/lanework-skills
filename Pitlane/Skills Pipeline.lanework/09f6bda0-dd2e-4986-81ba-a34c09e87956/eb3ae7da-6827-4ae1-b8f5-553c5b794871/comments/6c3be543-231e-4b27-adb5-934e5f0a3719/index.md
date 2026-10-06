---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:09:24Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T23:09:24Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Started on branch `rename-skills`. The owner set the release to 0.2.0, and the body's version line now says so.**

**Order**: built after the heal, guide-stamp and pointer branches merged, as planned. The merge-skill branch is still in build, and whichever of the two lands second rebases. Smoke's citation check catches any old `pitlane/` path left behind.
**Lead's part at merge**: the `~/.claude/skills` links are renamed when the branch lands on main, not before. Until then they point at the old folders.
