---
schema: 1
kind: comment
in-reply-to: 6c7b85a1-4379-40bb-b539-732679614bf9
created:  {at: 2026-10-10T12:01:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:01:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Recorded: the move works on the skills' side, but the app did not reopen the moved board on its own. Its done-when item fails for an app reason.**

- **Seen** (ZoneCanary Pipeline, `Pitlane/` → `Lanework/`): the welcome window listed both locations, each marked "board root is unreadable: no such file or directory". A double-click opened the new one fine and cleared its error. The old entry kept its error.
- **App gap 1, relocation**: the id-based relocation search this card relied on (its Risk line) did not find the moved board. Even the new path's entry was marked unreadable until opened by hand.
- **App gap 2, stale entry**: the old location is never dropped or merged into the new one, so it stays as a broken row.
- **Skills side**: none needed. The folder moved, the board validates and opens. The offer in `lanework/references/finding.md` could warn that one manual open is needed after a move, until the app is fixed.
