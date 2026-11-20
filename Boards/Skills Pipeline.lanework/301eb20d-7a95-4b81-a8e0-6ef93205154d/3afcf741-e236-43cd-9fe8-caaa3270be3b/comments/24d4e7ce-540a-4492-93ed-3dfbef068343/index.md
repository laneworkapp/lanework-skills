---
schema: 1
kind: comment
created:  {at: 2026-11-20T13:44:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped and moved to Proposed, 2026-11-20. No open calls.**

- **Shaped by**: a `fixer`-tier subagent (claude-sonnet-5-5), body read by the lead before the move.
- **Measured** on throwaway boards: both filed faults hold. An ask that opens with another person's handle passes unlinted; a record quoting the any-human handle in backticks is refused on a board with only `AGENTS.md`, and with no board argument.
- **Approach**: a handle that starts line 1 makes the body an ask for that person; the no-board fallback strips code spans and URLs first; `owner_handle` falls back to `AGENTS.md`; the dead smoke fixture goes.
- **Rejected**: a caller flag, since every caller would need it.
- **Order against [the handle-free asks card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/675df1a2-580f-4171-a744-262eca11d380)**: build this one first. It leaves ask detection in one step, and that card adds its clause there. No overlap in behavior.
- **Accepted**: a record that opens with a person's handle is now linted as an ask.
- **Not re-checked**: the old body's claim that 0.8.0 behaves the same.
