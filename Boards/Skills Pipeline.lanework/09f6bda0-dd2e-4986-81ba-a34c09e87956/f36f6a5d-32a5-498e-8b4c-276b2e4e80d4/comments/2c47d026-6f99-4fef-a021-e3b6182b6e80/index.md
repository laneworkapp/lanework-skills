---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:06:27Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "skills chat"}}
modified: {at: 2026-10-25T01:06:27Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "skills chat"}}
---
@rzen Should `/dispatch` ship beside `/watch` for a trial, or should `/watch` adopt dispatch routing now?

- A: separate command for a trial, folding `watch` events and responding into `dispatch` once the numbers hold
- B: `/watch` adopts routing now and the thick path retires in the same release

Why now: the Files section of [f36f6a5d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f36f6a5d-32a5-498e-8b4c-276b2e4e80d4) hangs on it.
If no answer: A.
Context: body ▸ Open calls.
