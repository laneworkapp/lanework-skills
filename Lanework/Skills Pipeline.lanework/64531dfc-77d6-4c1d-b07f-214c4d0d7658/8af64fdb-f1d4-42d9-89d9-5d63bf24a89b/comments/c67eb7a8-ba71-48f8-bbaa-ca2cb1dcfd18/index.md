---
schema: 1
kind: comment
in-reply-to: 54819345-cde7-48be-8fe7-b83431ea77ff
created:  {at: 2026-10-25T01:12:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T01:12:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Recorded: automated, so C (the hand check) is out. Both remaining routes are automated. They differ in what they cover and where they run. I recommend A, refreshed at each guide bump.**

- **Gap they close**: `tests/merge-case.sh` already runs every conflict row as a merge, a rebase, with no driver, clean, as a rebase move and dirty. All of those use scripted edits on both sides. Missing: a side whose bytes the app wrote.
- **A, app-written fixtures**:
  - **What**: `tests/fixtures/app-writes/` holds real app output, taken from this board's git history: an unstamped lane rewrite, a card moved in the app, an app-posted comment with its quoted `{name: "…", kind: "human"}` stamp, an app title edit and the app clearing `waiting`. A `README` names each file's source commit.
  - **How it runs**: a new `appside` mode in `merge-case.sh` puts those files on clone B, scripts edits to the same items on clone A, merges, and asserts no prompt, no markers, and the board validates. Smoke and CI run it.
  - **Weak spot**: it freezes the app's format as of the copy. **Fix**: smoke already fails when this board's guide is newer than the stamp. Re-copying the fixtures becomes part of that same bump, so they can't drift silently.
- **B, live app through Shortcuts**:
  - **Checked today**: the app ships App Intents for create card, move card, add comment, find cards and re-stamp labels. `shortcuts list` on this Mac shows no Lanework shortcut yet, so one has to be built first.
  - **Covers**: those four writes, on the current build. **Doesn't cover**: body edits, lane rewrites and title edits. No intent exists for them.
  - **Runs**: only on a Mac with the app installed. Not in CI.
- **Neither covers**: the app redrawing a merged board on screen.
