---
schema: 1
kind: comment
created:  {at: 2026-10-30T14:56:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-30T14:56:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
in-reply-to: 88020410-a24e-4baa-b333-6e5afd567627
---
**In plain terms: after you answer a question on a card, does the runner's next job remember the earlier conversation, or start from the card alone?**

A job that asks you something ends there. Your reply starts a new job later. This decides what that new job knows.

- **A**: starts blank and reads the card and its thread. The board is the only memory. Context stays small, but anything not written on the card is lost.
- **B**: picks up the earlier job's conversation where it stopped. Nothing is lost, but each round adds to what the job carries.
- **C**: picks it up if the earlier job is under a day old, else starts blank. A middle path, with a cut-off to tune.

Why now: it decides how the runner keeps context flat across an ask and your reply.
