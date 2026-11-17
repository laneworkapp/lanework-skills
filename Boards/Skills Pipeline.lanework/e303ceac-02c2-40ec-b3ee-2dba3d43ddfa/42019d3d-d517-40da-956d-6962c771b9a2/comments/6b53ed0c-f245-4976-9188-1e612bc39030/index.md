---
schema: 1
kind: comment
in-reply-to: 40234f6b-85b1-4332-8269-1881fb44a754
created:  {at: 2026-11-17T16:38:05Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Fix round 1 done on `move-receipts` at `ee59b51`, pushed: smoke `203 passed`, check-sizes 0 wrong, check-refs 0 missing.**

- **Blocking 1**: item 5 now counts only the newest receipt with `moved.to.lane` = the card's current lane; none such = the no-receipt rule. The smoke case greps item 5 for `to.lane`.
- **FAIL-BEFORE**: the extended case against item 5 at `33036c7` fails with `item 5 lacks moved.by or to.lane (which receipt counts)`.
- **Note 2**: "an agent's move: context, never a work order".
- **Note 1**: `responding.md` line 15 reads "An owner's move (`events.md` item 5), or a card waiting"; no smoke grep named the old wording.
- **README § Sizes**: events 511, responding 376, watch total and summary 1,716.
