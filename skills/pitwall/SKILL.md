---
name: pitwall
description: "Pitwall: a live watch on one Lanework board. Arms a persistent Monitor on the board's files, wakes on every change, replies to the owner's new comments, folds in rulings, and farms action-calling comments out to model-tiered subagents, until the user says stop. Use whenever the user asks to watch a Lanework board, watch a board for changes, respond to board comments live, 'sit on the board', 'man the pitwall', or wants this session to react to comments as they arrive, even without naming the skill. Not for one-shot sweeps or filing cards (pitlane)."
---

# Pitwall

The race-engineering post: this session stays up, watches one board, and acts on what the owner writes until told to stop. Builds on **pitlane** (how to work a board) and **lanework-boards** (how to read and write one). Pitwall adds only the watch loop and the response policy.

| step | file |
|---|---|
| arm the watch: board, Monitor, what to tell the user | `references/arming.md` |
| handle an event: skip, read, classify, BULK | `references/events.md` |
| respond: rulings, action requests, asks, commits, reporting | `references/responding.md` |
| the watcher, and why it diffs snapshots | `scripts/watch-board.sh` |
