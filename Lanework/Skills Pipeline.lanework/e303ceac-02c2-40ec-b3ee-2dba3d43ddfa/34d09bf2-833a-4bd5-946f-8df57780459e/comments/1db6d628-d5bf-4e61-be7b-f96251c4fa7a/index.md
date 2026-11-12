---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:08:17Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T11:08:17Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
**Filed from the round-2 review of [5f372bd4](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/5f372bd4-d140-46fa-9566-6ce1d628a728). A red smoke run that isn't real costs every build a re-run and a guess.**

**Evidence**: the reviewer traced the failure to SIGPIPE, not to that branch. The line dates from `8a3dd62`, and the branch doesn't touch it.
**Decided**: same defect class as the `yes | head` fix that branch needed in its own new case, so the fix sweeps the whole file.
