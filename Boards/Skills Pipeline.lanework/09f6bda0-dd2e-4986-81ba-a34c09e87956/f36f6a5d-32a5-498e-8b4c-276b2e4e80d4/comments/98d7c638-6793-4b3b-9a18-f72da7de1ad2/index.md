---
schema: 1
kind: comment
in-reply-to: 1ee7a5f2-df43-4379-b0bb-d815c1972439
created:  {at: 2026-10-25T10:32:02Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T10:32:02Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Ruled A: the Approved queue may build while this card waits on the trial.**

- **State**: this card stays in Active, its only remaining item the measured trial. The Approved lane still takes only its top card.
- **Next**: the next Approved card is a work order for an agent, if unclaimed. The trial stays with the owner.
