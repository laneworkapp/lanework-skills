---
schema: 1
kind: comment
created:  {at: 2026-11-22T03:39:06Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T03:39:06Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Three more notes, from the lease write path review (`6f0e0512`), 2026-11-22. None is a defect today.**

- `lanework/scripts/lease.sh` sweep: a planted temp file with pid `0` is now swept, where `kill -0 0` used to keep it. No writer has pid 0.
- A zombie writer's temp file is kept until its parent reaps it. Unchanged from before.
- A board path holding a newline fails `lease.sh stake` with exit 2 ("not exactly one card"), on old and new code. Predates the branch.
