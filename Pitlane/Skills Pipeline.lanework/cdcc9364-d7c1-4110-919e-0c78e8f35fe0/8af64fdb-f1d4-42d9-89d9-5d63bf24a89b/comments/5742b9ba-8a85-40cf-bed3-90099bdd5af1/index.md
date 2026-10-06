---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:44:24Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T22:44:24Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
---
**Filed from the owner's ask for a fifth skill: boards shared through git conflict constantly, and nearly all of it is mechanical.**

- **Decided**: name `merge`, the owner's suggestion. Generic like `watch` and `work`, with the same symlink-install caveat.
- **Decided**: a merge driver plus a post-merge pass, not one or the other. The driver handles the common case with no agent present. Rename and delete conflicts are tree-level, which a driver never sees, so the pass is still needed.
- **Decided**: later `modified` stamp wins state. It is the one signal both sides already write, and a move or trash restamps it.
- **Rejected**: ours-always or theirs-always. Loses real work silently. Prompting the human per conflict: the owner's brief rules it out.
- **Open**: what to do when both sides edited a body. Three options in the body, asked below.
- **Accepted limitation**: a side that forgot to restamp `modified` loses state ties to the side that did.
