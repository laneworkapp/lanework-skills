---
schema: 1
kind: comment
created:  {at: 2026-10-30T14:56:27Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T14:56:27Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
in-reply-to: d895a240-c672-431e-8819-7f8bddb2e648
---
**B trades isolation for one shared budget: one process can cap jobs and spend across every board, but one fault stops them all.**

Gains of B:

- One launchd job and one install, however many boards.
- One job queue, so it can cap concurrent builds and model calls across all boards. That matters more now that builds are in phase 1 and every event costs a model call.
- The same argument shape as `/watch`, which it is meant to replace.

Costs of B:

- A crash or hang stops every board, not one.
- Its state must be keyed by board: in-flight jobs, self-writes, queues.
- A long build on one board can hold up another unless each board gets its own queue.
- Adding or dropping a board means editing and restarting the shared job.
- Two boards with the same folder name collide, as they do in `/watch` today.
- The app would later hand the runner a board list, not one board path.
