---
schema: 1
kind: comment
created:  {at: 2026-11-14T15:01:34Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T15:01:34Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Shaped, and moved to Proposed: no open call remains.**

- **Body**: rewritten as a proposal: every file under `skills/` and `tests/` it touches, nine named smoke cases, a checkable done-when, risks, dependencies and a recommendation.
- **Decided here, inside the rulings**: `state.sh` is unchanged (its claim is the router's in-flight set, the lease is the cross-session claim). `arm-pass.sh` gains a report-only `held` line and reads leases through `lease.sh list`. A lapsed lease stays report-only in the arming pass, since a takeover waits two minutes and a router must not block. A `bulk` handler reports the cards it finds as `orders:` and the router stakes and spawns per card, because a subagent never stakes and the router cannot name bulk cards before the diagnosis.
- **Found in the code**: `arm-pass.sh` and `companions.md` both define a claim as a START comment, so ruling Q5 changes them. A lease renewal restamps `modified`, which `classify-event.sh` reads to judge a move's author: a rare misread, listed under Risks.
- **Needs from card 0f83a9dd**: `lease.sh list` must print each held card's uuid and minutes left or lapsed, with the 35-minute clock guard applied.
