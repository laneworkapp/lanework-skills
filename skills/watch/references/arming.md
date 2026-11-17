# Arming the watch

Once, at start.

## Rules

Read `work/SKILL.md` and, through it, `lanework/references/authority.md`, by path. The watch can't rely on the model loading either skill.

## Boards

Each `/watch` argument is a board name or path:

- Path → that board.
- Name → match `<Name>.lanework` in the project's board folders, then `~/`'s (`lanework/references/finding.md`: folders, order, legacy offer, run before arming). No match or several → ask.
- No arguments → the one board across the project's board folders (`lanework/references/finding.md`: folders, order, legacy offer, run before arming). More than one, or none → ask which.

Then, **per board, now**: read the guide, the board body and **every lane body**, so later wake-ups act without re-reading. A lane body is the only place a lane says it's out of scope for agents.

## Arming pass

Once per board, after the reads. No event fires for what is already sitting, so classify every card now: `scripts/arm-pass.sh <board>`, passing every agent lane title when the board's bodies name lanes other than the `agent` rows of `lanework/references/board-kinds.md` (titles passed replace those rows, not add to them). A lane whose body puts it out of scope: its lines are skipped. Per line:

| line | do |
|---|---|
| `comment` | read the card whole (`events.md` item 3). Already answered (a later agent record answers it, or its ruling is folded in the body) → no reply, one report line. Else answer it as a new owner comment (`responding.md`). Either way, then carry on as `arm` when the card sits in an agent lane with no valid lease (Approved: its top card; a `held` or `stale` line for the same card right after = a lease, so no), because the script prints `comment` in place of `arm`. A thread answered without `in-reply-to` prints this line falsely; reading the card catches it |
| `arm` | a card in an agent lane with no valid lease = work order, only when the lane body agrees and the card waits on nobody (no `waiting`): `responding.md` § A move into an agent lane. Else one report line. A START or plan comment is not a claim: only a lease is (`lanework/references/writes.md` § Lease) |
| `held` | report only: a valid lease, minutes left. Lane, title, minutes, in the arming message (§ Tell the user). Never worked, whoever holds it |
| `stale` | report only: a lapsed lease, minutes since its `until`. Same report place. Never worked, never taken over, never released: the owner frees it, or asks an agent to take it through `work` (the takeover waits two minutes, which an arming pass must not block on) |

Done is never swept. A card in a non-agent lane: no work order, report. The script reads leases once through `lanework/scripts/lease.sh list` and writes nothing. That call failing = exit 1 with `comment` lines only and a stderr note: report it, arm nothing that pass.

## Monitor

One persistent Monitor (`persistent: true`) for all boards:

```bash
<skills>/watch/scripts/watch-boards.sh --skills '<skills root>' '<scratchpad>/board-snapshot.txt' '<absolute board path>' ['<absolute board path>'...]
```

- `<skills root>` = the folder holding `watch/`, `work/` and `lanework/`, each a real folder or a symlink (a root without `watch/SKILL.md` is refused). Symlinked and in-place installs only; plugin installs re-read on a new `/watch`. The watcher fingerprints the rule files and emits `SKILLS CHANGED` when they change, live or since the last arm (`events.md` item 8).
- Needs homebrew `fswatch`. Absent → run the same snapshot diff in a plain 2s `sleep` loop.
- Two boards with the same folder name → refused. Give each its own Monitor and state file.
- **Don't "improve" the watcher by filtering fswatch paths.** Why: the script's header. That header is load-bearing history.

## Tell the user

- Which boards are watched.
- What the arming pass reported: held cards (minutes left), lapsed leases (minutes since `until`) and other report-only lines.
- The watch runs until TaskStop or session end. It dies with the session and must be re-armed after a resume (`/watch` again).
- "Stop" tears it down (TaskStop). Watching fewer boards = stop and re-arm with the rest.
- The Monitor **survives `/clear`**: events keep arriving without this context. After a clear, re-read each board's authority chain before acting on one, or tear the watch down if the user has moved on.
- After a **compaction**, re-read each board's authority chain before acting, and re-derive work in flight (running builds, held leases, pending asks) from the board and git, never from the summary. A card path comes from `ls`, never from memory.
