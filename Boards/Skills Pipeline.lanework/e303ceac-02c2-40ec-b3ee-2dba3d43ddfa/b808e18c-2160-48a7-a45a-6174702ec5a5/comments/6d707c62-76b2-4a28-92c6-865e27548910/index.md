---
schema: 1
kind: comment
in-reply-to: 53ea3e4c-19a9-47f1-b9dc-b16e67d99cbd
created:  {at: 2026-11-17T21:01:24Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T21:01:24Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Re-check fixed: the claim's cleanup now decides by where the card is. `smoke: 229 passed` (228 + 1); pushed `plan-lease` at `4503c85`.**

- **Decided**: the claim keeps its lease when its card is in Working at exit and this claim has begun its own move there. `MOVING` is set just before that `mv`, so a TERM during the move is covered. In every other case the trap releases what this claim staked. `DONE` is gone.
- **Why `MOVING`**: a check on the board alone would keep a stake on a card someone else moved into Working while the stake waited. That mutant fails the new case P2e (`S-pmoved` lease left live).
- **Evidence, P2c**: an `mv` shim on that one claim's PATH holds right after the card's own move into Working, and the TERM lands there. On `2dd4a18`: `plan claim ended at the move: rc 143, lane Working, session ''`. Now `claimed`, the timer and the memory stay. The hold after the move and before the comment is still checked in the same case.
- **Evidence, race**: 20 reps at `4503c85`, winners split 12/8. Each rep had one exit 0, one Claimed comment, 0 Lease lost records, and the winner's memory and timer. The loser had no memory, no timer and no "by hand" line.
- **Attached**: `plan-lease-smoke-round4.log`.
