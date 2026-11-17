---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:40:29Z, by: {name: shaper, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:40:29Z, by: {name: shaper, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Shaped: four of the seven "Shaping settles" items are settled by code or rulings. Order, the Active cards and the version are open calls A to C in the body.**

- **Tiers, settled by ruling**: [f36f6a5d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f36f6a5d-32a5-498e-8b4c-276b2e4e80d4) § Decided, owner 2026-10-25: tiers as-is. `dispatch/references/routing.md` § Spawn only applies it to handlers. Watch has no handlers, and `watch/references/responding.md` § Action-calling already farms per `tiers.md`.
- **`arm-pass.sh` output, settled by code**: watch uses every field. `tests/smoke.sh` lines 960-974 pin the full lines, and [9c5ee0c7](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233) adds `held` in the same seven fields. The header (lines 2, 10-11) is the only edit.
- **`classify-event.sh`, settled by ruling**: Board Runner Discovery Q3, ruled C on 2026-10-30, ADR "The run skill owns its trigger rules": the runner does not reuse dispatch's classifier.
- **False alarm, settled by the guide**: § Comments makes `in-reply-to` the mark of an answer, so the script stays strict and watch reads the card before replying.
- **Open cards naming dispatch, settled by code**: listed per card under Dependencies. Proposed is the owner's gate, so their bodies are not edited from here.
- **Evidence, read-only run**: `skills/dispatch/scripts/arm-pass.sh` on this board printed five lines. Two were `comment` false alarms ([d42328d4](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7), [714177b9](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3)). Two were `arm` for the Active dispatch cards, which wait on the owner. The fifth was `arm` for this card.
- **Found wrong in the filed body**: watch already has an arming pass for unclaimed agent-lane cards (`arming.md` line 19). What it lacks is the owner-comment and stale-claim sweep. The board's `skill` kind is open, so no label value exists to remove, only the body sentence.
- **Found in the tests**: the arm-pass smoke block uses `NOWS`, `OLD` and `AGENT` from the dispatch block (lines 863-864). `check-sizes.sh` walks only existing folders, so a leftover `dispatch` row would pass. Both are in the body.
- **Rejected**: trimming the script's output. It is churn against smoke and the lease card for no gain.
