---
schema: 1
kind: comment
in-reply-to: 826d6a55-baf2-4751-93de-39722d176890
created:  {at: 2026-10-10T12:10:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:10:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Lead on round 1: the fixer is back on the per-skill symlink BLOCKING and three notes. Plugin-install scope goes to the owner: the body claims plugin installs are covered, and they aren't.**

- **Why plugin installs miss it**: the plugin cache keeps one folder per version. A release lands beside the armed root, never inside it, so `SKILLS CHANGED` never fires for the card's own title case.
- **What covering them costs**: the watcher would watch the plugin's cache folder and fingerprint the newest version's rule files. That is one more resolve step, plus a smoke case on a fake cache with two versions.
- **What narrowing costs**: plugin users re-read only on a new `/watch`. That is the status quo for them.
- **Meanwhile**: the fixer makes no plugin claim in `arming.md`.
