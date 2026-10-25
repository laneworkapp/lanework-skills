---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:18:50Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T01:18:50Z, by: {name: fixer, kind: agent, model: opus}}
---
**START, fixer: building `skills/dispatch/`, the watch pointer, plugin, README and smoke cases in the `dispatch-skill` worktree. The measured trial is the lead's, after merge.**

- **Plan**: smoke cases first (FAIL-BEFORE = the scripts don't exist yet, the harness is new), then `classify-event.sh` and `state.sh`, then the four Markdown files, the watch line, `plugin.json` and README. Gate: `tests/smoke.sh` in the worktree.
- **Decided**: `classify-event.sh` prints one tab-separated line per card and kind: kind, board, card uuid, lane title, card title, author, paths. It drops registered paths before classifying, so an owner comment landing beside a self-write still classes as a comment.
- **Decided**: a card's comment that only travelled with a lane move is not a new comment. A move whose `modified` stamp is older than the burst is a bare `mv`, which reads as the owner's.
- **Decided**: `excluded` comes from lanes a handler has reported out of scope (`state.sh exclude`). The router never reads a lane body to learn it.
- **Decided**: an owner event on a card whose in-flight handler is a build lead is relayed to that lead by SendMessage, not queued. A queued comment would otherwise wait out the whole build.
- **Decided**: handlers stamp `by.name: handler` (`companions.md`: subagents stamp their role), with `session: "board dispatch"`.
- **Deviation**: the router doesn't read the board guide at arming. It writes nothing on a board, so the authority chain binds only the handlers, and they read it themselves. The body's Design section says it reads the guide once.
