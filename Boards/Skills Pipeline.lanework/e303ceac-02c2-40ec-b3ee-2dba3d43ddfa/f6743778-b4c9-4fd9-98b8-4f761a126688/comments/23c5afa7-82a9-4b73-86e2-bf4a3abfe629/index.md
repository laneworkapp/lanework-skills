---
schema: 1
kind: comment
created:  {at: 2026-11-21T13:21:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; moved to Proposed for review.

All four items are kept and reproduced on throwaway boards. The cause is wider than filed: a name or model that starts with a quote, bracket or other YAML indicator, or holds a colon-space, also writes an invalid stamp, several scripts exit 0 while doing so, and the merge driver writes `model` unquoted. The proposal is one quoting rule in `lib.sh` that leaves every existing stamp byte for byte, plus a refusal for values no quoting can carry. No open call.

Overlap: the lease leftovers card `ae676e47` also touches the session id check in `lease.sh`. Build that one first and this one on top.
