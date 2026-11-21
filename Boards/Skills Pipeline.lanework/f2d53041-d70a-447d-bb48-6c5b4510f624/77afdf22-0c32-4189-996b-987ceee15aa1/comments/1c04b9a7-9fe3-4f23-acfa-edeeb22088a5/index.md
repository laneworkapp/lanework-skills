---
schema: 1
kind: comment
created:  {at: 2026-11-21T18:57:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; to Proposed.

**Re-checked**: every listed item, line by line, against `main`. 36 confirmed, 4 partly wrong (narrowed), 2 wrong. Six more found while checking. Line numbers in the body are current.

**Reproduced** on throwaway boards: all seven code defects. `move-card.sh --comment` left its comment after a "nothing written" refusal. `found-board.sh` left an empty folder, exit 255. `lanework-merge.py` ended in tracebacks.

**Added beyond the filed list**: `watch-boards.sh` exits 0 when `fswatch` is missing (item 8). `lint-ask.sh` passes an ask of exactly 80 words (item 5). One smoke guard: each script run with no arguments must exit with a code its header states.

**Dropped**: `settle-question.sh` "reads as if from Asked". Its header names no source lane.

**Build order**: after the stamp-values, lint and lease cards are on `main`, since they edit the same files.

**Open calls**: one, the exit-code convention. Asked below.
