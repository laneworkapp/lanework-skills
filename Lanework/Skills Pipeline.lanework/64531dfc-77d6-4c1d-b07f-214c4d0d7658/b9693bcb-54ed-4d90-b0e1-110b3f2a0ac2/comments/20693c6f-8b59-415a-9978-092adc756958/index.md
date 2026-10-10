---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:51:41Z, by: {name: shaper, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:51:41Z, by: {name: shaper, kind: agent, model: sonnet}}
in-reply-to: be08401d-8081-45c3-aa46-3040d5f76860
---
**Not needed now: the card's own test (do Proposed cards bounce back to Shaping?) measured zero, so nothing here earns an agent per shaping job.**

- **Evidence**: this repo's git history of the board, rename-detected card moves: 7 cards entered Proposed, 0 moved from Proposed back to Shaping. Population is 7. This board has no `.log/`, and a bounce inside one commit would not show, so the zero is a floor on evidence, not proof.
- **What the skill says today**: `work/references/team.md` still has the roster row "proposal reviewer: not defined yet". `work/references/reviewer.md` reviews one card's branch only (merge-base diff, fail-before, blast radius), nothing about proposals. `work/references/sweep.md` lists Shaping as "farm: shape" and Proposed as a human gate, report only.
- **What covers it**: the owner's review at the Proposed gate. The board's ready-to-build bar (files under `skills/`, how verified, a checkable done-when). Open calls going out as asks, so the owner rules them before approval. The duplicate search before a finding is filed (`work/references/sweep.md` § 5).
- **Accepted limitation**: the owner stays the only reviewer of proposals.
- **Rejected for now**: defining the row. Review that cannot change a verdict is the E0 case in `work/references/evidence.md`.
- **Revisit when**: a card bounces from Proposed to Shaping for a reason a second reader would have caught.
- **Edited**: title and body renamed from pitlane to work; scope unchanged.
