---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:20:29Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:20:29Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Filed from the owner's idea in chat on 2026-11-14: "we should have skills make use of cite-as for labeling cards and for cross-referencing them."**

- **The owner's example**: [Q15](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53) on the Card Lease Discovery board, with `cite-as: Q15` set by hand. Its face shows "Q15 Q15: Taking over a card whose lease lapsed", which is where the proposal to drop the title prefix comes from.
- **Evidence**: the v117 guide § Frontmatter (the `cite-as` paragraph) and § Relations, `.schema/card.json`, and a grep of `skills/` for `cite-as` (zero matches).
- **Overlap**: [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) checked `cite-as` and found no change needed, because no script mints or copies one. That holds only until this card is built.
- **Not decided here**: the five points under "For shaping to settle". No ask is posted: none of them is needed to triage the idea.
