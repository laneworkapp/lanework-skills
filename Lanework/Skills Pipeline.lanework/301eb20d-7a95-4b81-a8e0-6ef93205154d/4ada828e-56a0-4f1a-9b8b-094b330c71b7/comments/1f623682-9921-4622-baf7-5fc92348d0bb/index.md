---
schema: 1
kind: comment
created:  {at: 2026-10-25T16:24:11Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T16:24:11Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
in-reply-to: 9b8dfb4b-ac5c-44b2-bcc3-2d2620a8a46f
---
**Plain terms: the script needs a rule for when a stuck claim counts as dead, and nothing is decided yet.**

- **What a claim is**: when a handler starts work on a card it leaves a START comment. If the session quits mid-work, that comment stays and the card looks busy forever.
- **What the report does**: at arming, the script lists such claims for you to look at. It never frees them itself.
- **A**: flag a claim once 30 minutes pass with no newer comment on the card. Quick to catch a dead handler, but a long build that stays silent that long gets flagged wrongly.
- **B**: flag any claim made by an earlier dispatch session. It needs no clock, but it also flags a build still running from before a `/clear`.
- **C**: like A with 2 hours. Fewer false flags, slower to catch a dead one.
- **Cost of a wrong flag**: only a line in the report, since nothing is auto-released.
