---
schema: 1
kind: comment
created:  {at: 2026-11-11T23:17:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Main"}}
modified: {at: 2026-11-11T23:17:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Main"}}
---
**Filed at the owner's request, from a report relayed by the Lanework Pitwall session. A future stamp corrupts thread order, and later agents copy it forward.**

**Evidence**: Lanework Pipeline card 68468c50, record d8ad69ab (app repo). Checked here: `writes.md:7` gives only the shape. `work/scripts/` has only `lint-ask.sh`. `now_utc` is used by nine scripts in other skills, none in `work`.
**Decided**: the rule allows the deliberate one-second ask offset, taken from the clock. "Never in the future" would break it.
**Not here**: the validator WARN is the app side's. Pitwall is fixing its own coordinator briefs, which also left out `date -u`.
