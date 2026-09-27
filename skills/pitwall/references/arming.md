# Arming the watch

Once, at start:

1. **Load pitlane** (and, through it, lanework-boards). Read the guide, the board body **and every lane body now**, so later wake-ups act without re-reading. A lane body is the only place a lane says it's out of scope for agents.
2. **Resolve the board**: `lanework-boards/references/finding.md`, or the path the user names. Ask only when none is named and more than one exists.
3. **Arm a persistent Monitor** (`persistent: true`) on this skill's watcher:

```bash
<skills>/pitwall/scripts/watch-board.sh '<absolute board path>' '<scratchpad>/board-snapshot.txt'
```

- Needs homebrew `fswatch`. Absent → run the same snapshot diff in a plain 2s `sleep` loop.
- **Don't "improve" the watcher by filtering fswatch paths.** Why: the script's header. That header is load-bearing history.

Tell the user:

- The watch runs until TaskStop or session end. It dies with the session and must be re-armed after a resume.
- "Stop" tears it down (TaskStop).
- The Monitor **survives `/clear`**: events keep arriving without this context. After a clear, re-read the authority chain before acting on one, or tear the watch down if the user has moved on.
