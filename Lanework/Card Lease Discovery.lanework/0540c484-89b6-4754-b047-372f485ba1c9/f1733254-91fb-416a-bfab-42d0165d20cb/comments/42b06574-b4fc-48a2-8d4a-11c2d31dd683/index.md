---
schema: 1
kind: comment
created:  {at: 2026-11-14T13:47:50Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:47:50Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
in-reply-to: 8bc92058-0cf4-47d9-8cba-aaaab3a26e69
---
**Why A: it settles the race with nothing new to create, leak or clean up, and its one gap needs a stall of over a second inside one script run.**

- **How A works**: two agents both read the card as free, and both write `claimed`. A file write replaces the whole file, so the last writer's `by` is what stays. Each waits a second and reads again: the one whose `by` is still there holds the lease, and the other sees a different `by` and backs off.
- **A's gap**: if an agent reads "free" and then stalls for more than the wait before writing (machine asleep, disk hung), its late write lands after the other agent's read-back, and both believe they hold the card. The script does the read and the write in one run, a few milliseconds apart, so this needs an unusual stall. The lease is cooperative anyway (Constraints, Topic).
- **Why not B**: an atomic `mkdir` lock has no gap. It costs a lock folder outside the board, and a session killed while holding it leaves a stale lock to reclaim by age. The lock is held for milliseconds, so that is rare too. B is the stronger choice if a gap of any size is unacceptable; A is the smaller one.
- **Why not C**: a folder rename is atomic, but it makes staking depend on a lane. Every board kind would need a "taken" lane, and a card's lane would mean two things: its stage, and whether it is held. `plan` does this today with Working, and the map keeps that question for later.
- **What decides it**: whether a gap that needs a stall of over a second is acceptable on a cooperative lease. If yes, A. If no, B.
