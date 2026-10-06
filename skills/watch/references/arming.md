# Arming the watch

Once, at start.

## Rules

Read `work/SKILL.md` and, through it, `lanework/references/authority.md`, by path. The watch can't rely on the model loading either skill.

## Boards

Each `/watch` argument is a board name or path:

- Path → that board.
- Name → match `<Name>.lanework` in the project's `Pitlane/`, then `~/Pitlane/` (`lanework/references/finding.md`). No match or several → ask.
- No arguments → the one board in the project's `Pitlane/`. More than one, or none → ask which.

Then, **per board, now**: read the guide, the board body and **every lane body**, so later wake-ups act without re-reading. A lane body is the only place a lane says it's out of scope for agents.

## Monitor

One persistent Monitor (`persistent: true`) for all boards:

```bash
<skills>/watch/scripts/watch-boards.sh '<scratchpad>/board-snapshot.txt' '<absolute board path>' ['<absolute board path>'...]
```

- Needs homebrew `fswatch`. Absent → run the same snapshot diff in a plain 2s `sleep` loop.
- Two boards with the same folder name → refused. Give each its own Monitor and state file.
- **Don't "improve" the watcher by filtering fswatch paths.** Why: the script's header. That header is load-bearing history.

## Tell the user

- Which boards are watched.
- The watch runs until TaskStop or session end. It dies with the session and must be re-armed after a resume (`/watch` again).
- "Stop" tears it down (TaskStop). Watching fewer boards = stop and re-arm with the rest.
- The Monitor **survives `/clear`**: events keep arriving without this context. After a clear, re-read each board's authority chain before acting on one, or tear the watch down if the user has moved on.
