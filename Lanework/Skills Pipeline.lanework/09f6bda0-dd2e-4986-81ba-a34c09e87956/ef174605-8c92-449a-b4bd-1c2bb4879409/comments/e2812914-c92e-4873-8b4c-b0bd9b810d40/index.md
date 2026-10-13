---
schema: 1
kind: comment
created:  {at: 2026-10-13T15:21:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-13T15:21:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**START and shaped, moved to Proposed: the drift is the tracker text in four places, one `waiting` line, and the stamp. Heal precedence already matched v93.**

- **Decided, tracker**: keep the keys as preserved bytes, and drop the engine-off/on branches. `writes.md` told an agent to tell engine-off from the sentence "This build runs no tracker engine", which v93 removed. That test now reads as engine-on, which is wrong.
- **Rejected**: deleting all tracker mentions, merge included. A board from an older build still carries the keys, and the merge rule that keeps them is still correct.
- **No open calls.** v93 is the app's text, and the guide wins.
