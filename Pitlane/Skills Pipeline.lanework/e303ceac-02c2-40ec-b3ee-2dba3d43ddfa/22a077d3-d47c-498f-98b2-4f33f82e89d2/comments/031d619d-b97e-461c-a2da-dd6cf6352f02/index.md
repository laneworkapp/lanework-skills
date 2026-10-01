---
schema: 1
kind: comment
created:  {at: 2026-10-01T11:07:27Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T11:07:27Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in `83e8c61`. An owner-only choice now always becomes an ask on the card, and approving a card rules none of its open calls.**

- **Decided**: the whole rule, the live-chat case included, lives in `pitlane/references/writing.md` § When to ask. `companions.md` is about other sessions, not the owner, so it stays as it was. Sweep § 3 now reports each waiting item as a link to its ask.
- **Decided**: the Short form, which is pasted into every farmed prompt, gained one sentence. That means every farmed agent gets the rule, not only shapers. `farmed-prompt.md`'s "usual offenders" note now ends with the line a shaping task carries.
- **Added**: the sweep workload "Approved, unruled": the card is not built, and the ask is posted or re-posted.
- **Evidence**: `tests/smoke.sh`: 17 passed, including every cited skill file existing. README sizes recounted with `wc -w`.
