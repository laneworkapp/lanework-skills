---
schema: 1
kind: comment
created:  {at: 2026-09-28T00:41:32Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:41:32Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Settled with the owner in chat. The assumption "app and skills always current, released together" holds closely enough to drop the runtime check.**

- **Facts from the owner**: Lanework is distributed directly, with no App Store review lag, and the app never writes an older guide over a newer one.
- **Remaining gaps, all temporary**: a board worked with no app running (cloud session, CI) can carry an older guide until an updated app opens it. A long-running session keeps skill text from before an update. Skill updates don't reach users on their own until [the marketplace card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/05809e25-fb9d-42de-b1af-22ec34fc227a) and [the versioning card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/040689be-e4b9-47f0-bdc7-91a0488feca6) land.
- **Why no runtime compare**: in each gap, the board's guide winning over the skills plus validation against the board's own schema already cover it. The only thing left is behaviour that validates but isn't in an older guide, and the one line handles that.
- **Rejected**: a rule for a board older than the target, keyed to the version. It would be dead text under this assumption.
- **Independent of**: the marketplace and versioning cards. Nothing here waits on them.
