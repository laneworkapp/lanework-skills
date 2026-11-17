---
schema: 1
kind: comment
created:  {at: 2026-10-25T16:30:09Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T16:30:09Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
in-reply-to: b4ff4b4c-3aec-49a5-a7e4-4908412ce092
---
**Option B trades a clock for a false flag on every live build that outlasts a re-arm; nothing is released either way.**

- **No session id exists**: every handler stamps the same `session: "board dispatch"`. B can only mean "a START older than this arm's start time", so the router must hand the script that time.
- **Live builds get flagged**: a lead still running across a `/clear` (which doesn't kill it) or a second dispatch on the same board has a START older than the new arm. It is flagged although alive. A long build flags again on every re-arm.
- **Old noise**: B has no age bound. Any START without a closing comment in the usual shape, however old, is flagged on the first arm. A closing comment in a different shape reads as still claimed (already a risk on the card).
- **Wrong flag cost**: only a report line. The risk is the owner freeing a live claim on that line, which lets a second handler build in the same worktree.
- **What B buys**: a dead handler is flagged on the very next arm, with no waiting for a timer, and a quiet long build never trips it. A and C miss a dead handler until the clock runs out.
- **Possible mix**: B plus a minimum age, for example only STARTs older than 30 minutes and older than the arm. That keeps B's quick catch after a quit and drops flags on fresh builds. It would be a fourth option if wanted.
