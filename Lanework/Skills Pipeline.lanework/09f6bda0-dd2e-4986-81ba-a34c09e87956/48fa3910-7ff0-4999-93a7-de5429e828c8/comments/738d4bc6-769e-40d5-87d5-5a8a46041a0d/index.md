---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:11:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:11:06Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
@rzen Should this card also cover plugin installs?

Options:
- A: yes, follow the newest plugin version in the cache
- B: no, cover symlinked installs only, and plugin users re-run /watch

Why now: the spec claims plugin installs and they are not covered.
If no answer: B, when the round-1 fix lands.
Context: the comment above.
