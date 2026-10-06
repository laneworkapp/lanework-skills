---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:32:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:32:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Guide v82 reached this board on 2026-10-06, so the priority line in `writes.md` is wrong now and this card no longer waits on the app.**

**Evidence**: v82 reserves `priority:` and `component:` at a card's root and puts both in `labels`. `skills/lanework/references/writes.md:10` still says the opposite.
**Also in v82**: the built-in free-label kind is `text`, not `default`, every label entry stamps its `kind`, and `background` is a mapping. The audit should cover these too.
