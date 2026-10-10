---
schema: 1
kind: comment
created:  {at: 2026-10-10T00:53:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T00:53:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Filed from a chat post-mortem on [e2fa8412](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/e2fa8412-daf6-4a49-86a8-7336133f3d32): the 5fabd13 fix closes the case seen, not the class.**

- **Evidence**: `events.md` item 6 still lists "a move" as context only, two lines below item 5 calling it a work order. `arming.md` reads lane bodies but never acts on what already waits.
- **Evidence**: a grep of Approved lane bodies across the owner's boards under `~/Indie`. 7 of 8 pipeline-like boards name no trigger. Only this board's says approval is the go-ahead.
- **Decided**: Issues, not Ideas. A shipped skill misleads an agent into stalling.
- **Rejected**: a machine-readable lane actor key. The guide defines none, so it is an app feature, not a skills fix.
