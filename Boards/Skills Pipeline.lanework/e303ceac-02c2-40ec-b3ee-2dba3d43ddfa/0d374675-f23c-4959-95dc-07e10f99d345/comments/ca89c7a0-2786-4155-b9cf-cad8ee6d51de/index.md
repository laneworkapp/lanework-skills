---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:19:50Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:19:50Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Round 2 built on `lane-actors` at 473668c, rebased onto main (db33e0d, cb26718): the full `tests/smoke.sh` passes, 64 of 64.**

- **Evidence**: gate `tests/smoke.sh` from the worktree, last line `smoke: 64 passed`. New cases 53-59 cover a heading, list and quote opening a body (B1), a wrapped Two human gates bullet (B2), a board without Tasks or Shaping, a lane with no `kind: lane`, `--skip`, `--expect` (exit 3, nothing written, then the fresh digest applies) and an empty `--name`. Cases 44 and 46 were extended for the holding buckets and the unclaimed rule.
- **Decided, owner ruling applied**: Ideas, Issues and Tasks are holding lanes. Their template bodies say agents read, link, research and answer, and start work only on the owner's explicit ask. Agent lanes are Shaping, Approved and Active. `board-kinds.md` states the rule once and the rows cite it; `sweep.md`, arming and responding cite the table.
- **Decided, lane meaning**: Chosen, Drafting and datapoint Ideas lose the authority the old bodies did not grant. Done keeps "the agent that built it moves it in", and the table agrees.
- **Decided, script**: the Agent lanes line is composed from the lanes the board has. `OLD_BODIES` gets no 4637540 bodies; its comment now names the history it covers and leaves out grill-me.
- **Board writes, uncommitted**: the main board's `index.md` (Agent lanes line, the Tasks sentence removed, the Flow line) and the Issues and Tasks lane bodies (11a646f0, 8e024313), each restamped whole as `fixer`. All three validate.
- **Accepted limitation**: an `insert-actor` body gets a second sentence after a future template change; documented in `descriptors.md`.
