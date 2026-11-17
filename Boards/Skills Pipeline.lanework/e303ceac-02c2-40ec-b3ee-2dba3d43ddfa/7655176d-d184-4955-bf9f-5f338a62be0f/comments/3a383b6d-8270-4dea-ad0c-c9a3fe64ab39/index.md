---
schema: 1
kind: comment
created:  {at: 2026-11-17T00:53:00Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-17T00:53:00Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Evidence: a hand-rolled "bottom of the lane" hung for 120 s on an empty lane, reported by the Lanework Main session at the owner's ask, 2026-11-16.**
- **What ran**: `grep -h '^order:' "$LANE"/*/index.md | awk '{print $2}' | sort -n | tail -1`, filing a card by hand into an empty Approved lane.
- **What happened** (that session's report, not re-run here): under zsh with `nullglob` the glob expanded to nothing, `grep` read stdin, and the harness killed it at its 120 s timeout. Nothing was written. Without `nullglob` the same line stops with `no matches found`.
- **Not a shipped bug**: no script under `skills/` has this line. `next_order` in `lanework/scripts/lib.sh` already returns 1024 for an empty lane, but it is a library function, so an agent filing by hand cannot call it as a command.
- **Same line here**: this session hand-rolled that pipeline twice on 2026-11-16 to move cards on this board. Both lanes had cards, so it did not trip.
- **Gap**: this card ships `move-card.sh`, `post-ask.sh` and `commit-board.sh`, and nothing files a new card on a pipeline board. Filing is where an agent re-derives the order, the stamps, the lane's default labels and the validator run.
- **Proposed addition**: `work/scripts/file-card.sh <board> <lane-title> <title> --body F --model m`, built on `next_order`, `union_lane_defaults`, `by_of` and `now_utc`, staged outside the board and validated after the `mv`. Plus one Shell row in `work/references/traps.md`: a glob over a lane's cards can match nothing, so give `grep` `/dev/null` as an extra file.
