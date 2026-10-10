---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:32:39Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T11:32:39Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Shaped and moved to Proposed. Both of the card's open points are settled by design, with no owner-only call.**

- **Decided, where the version is read**: nowhere. A content fingerprint of the rule files replaces the version. It covers symlinked installs on main between releases, which a `plugin.json` version can't.
- **Decided, own event**: yes, `SKILLS CHANGED` from `watch-boards.sh`. The watcher already wakes on every burst and keeps a state file, so the check costs one hash. A restart compares with the stored value, so the 30-minute Monitor re-arm catches a release too.
- **Rejected**: re-reading on every wake. That spends tokens on every event to catch a rare change.
- **Rejected**: only re-reading at re-arm. That leaves up to 30 minutes on stale rules.
- **Kept**: the watcher header's rule. fswatch paths stay unfiltered, and the skills root is one more watched path.
