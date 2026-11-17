---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:33:27Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**The arming half of the trial ran on 2026-11-16. The `/clear` and restart halves did not.**

- **How it ran**: `/lanework:dispatch` in the lanework-skills Pitwall session, on a rebuilt trial board. The original fixture had been emptied by the temp cleaner, so a subagent rebuilt the five cards from the trial-ready comment above. The session had the 0.7.0 plugin loaded, so the router read the 0.8.0 files by path. This is not a test of a fresh 0.8.0 install.
- **Arming pass**: `arm-pass.sh` printed exactly one `comment` (Ideas), one `arm` (Shaping) and one `stale` (Active, 45m). The answered Ideas card and the Done card printed nothing.
- **Handlers**: one Sonnet handler answered the owner comment in Ideas (`008c1af` on the trial board). A second shaped the Shaping card and posted an ask (`84dd4e6`). The stale claim was reported and not routed.
- **Self-writes**: every handler write came back from `classify-event.sh` as `self` and was dropped.
- **Seen on a board the app never opened**: with no in-board guide, the shaping handler guessed the ask's handle and copied the `waiting` shape from a discovery template.
- **Not run**: an owner comment arriving while dispatch was up, `/clear`, a restart. The session ended before any of them.
- **Found on this board, 2026-11-17**: `arm-pass.sh` printed `comment` for two Proposed cards whose rulings were folded long ago (d42328d4, 714177b9). Their agent records carry no `in-reply-to`, which is all the script reads. Older threads will show the same false alarm.
