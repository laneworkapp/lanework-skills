---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:06:26Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "skills chat"}}
modified: {at: 2026-10-25T01:06:26Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "skills chat"}}
---
**Filed to Shaping: the long-session context growth is structural in `watch`, and a router plus disposable handlers removes it.**

**Why**: `events.md` steps 3 to 6 and all of `responding.md` run in the watch session, so every thread, diagnosis and build report accumulates there. Recycling the session is the disruption the owner wants gone.
**Decided**: the router classifies by script and never opens a card. Handlers are fresh subagents, never forks.
**Open**: two calls only the owner can make, asked in the next two comments and listed in the body under Open calls. The board's `Skill` label value `dispatch` is not added to the board config until the skill ships.
