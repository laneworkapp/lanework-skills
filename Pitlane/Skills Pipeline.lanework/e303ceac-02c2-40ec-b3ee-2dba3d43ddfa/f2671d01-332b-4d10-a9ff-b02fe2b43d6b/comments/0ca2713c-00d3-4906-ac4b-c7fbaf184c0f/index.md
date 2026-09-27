---
schema: 1
kind: comment
created:  {at: 2026-09-27T21:16:25Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T21:16:25Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The owner asked for this in chat. Discovery is a long, interactive session that founds a board, so nobody starts one by accident. Its description only held loose triggers ("sharpen this plan", "let's think X through properly") so that Claude could start it. Those triggers were what made starting it by accident possible, and they cost about 970 characters of context in every session.

- Accepted limitation: `/discovery` only works as the first thing in a message. "Put X through /discovery" mid-sentence no longer starts it. The owner accepted this.
- Route not taken: keeping it model-invocable with a trimmed description of about 650 characters.
- The "grill me" carry-over triggers are dropped. They only mattered while Claude could start the skill itself.
