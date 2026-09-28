---
name: pitwall
description: "Live watch on one or more Lanework boards: replies to your new comments, folds in rulings, farms out requested work. Run as /pitwall <board>..."
disable-model-invocation: true
---

# Pitwall

The race-engineering post: this session stays up, watches one or more boards, and acts on what the owner writes until told to stop. Runs only as `/pitwall <board> [<board>...]`: names or paths, none → `references/arming.md` § Boards.

Builds on **pitlane** (working a board) and **lanework** (reading and writing one). Pitwall adds only the watch loop and the response policy.

| step | file |
|---|---|
| arm the watch: boards, Monitor, what to tell the user | `references/arming.md` |
| handle an event: skip, read, classify, BULK | `references/events.md` |
| respond: rulings, action requests, asks, commits, reporting | `references/responding.md` |
| the watcher, and why it diffs snapshots | `scripts/watch-boards.sh` |
