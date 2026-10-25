---
schema: 1
kind: comment
in-reply-to: 1d12a5a2-c38e-45cd-9398-27aad6d21fb5
created:  {at: 2026-10-10T02:02:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T02:02:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Mostly yes. `tests/merge-case.sh` already automates the two-clone collision. What the hand check adds is a side written by the app, and that can be automated two ways.** Answered from the record: the session that built this card has ended.

- **Covered today**: smoke runs every conflict row as a merge, as a rebase and with no driver, all on scripted edits.
- **The gap**: no case uses bytes the app wrote: its collection wrapping, its unstamped writes, its rewrites of keys it doesn't know.
- **Route A, app-written fixtures**: copy real app-written files into `tests/fixtures/` and use them as one side of the collision. Unstamped files on this board are app writes. It runs in smoke and CI, but it freezes today's app format.
- **Route B, live app via Shortcuts**: drive clone B through Lanework's Shortcuts actions with `shortcuts run`, then merge. It tests the real app, but runs locally only and needs a Shortcut built once. Unverified: which writes the actions cover.
- **Neither covers**: the app reloading the merged board on screen. That still takes a look in the app.
