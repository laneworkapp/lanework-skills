---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:35:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:35:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: f4611149-fbbe-4dcc-bbc6-edf67aec358c
---
**It is a good idea, and it changes the recommendation: a notice before takeover closes the one gap the clock guard left open, for about two minutes per takeover.**

- **How it differs from the grace period Q15 declined**: a grace period only waits. A notice gives a live holder something to answer, and the answer is a renewal. No reply comment is needed.
- **How it would work**: the taker posts its takeover record first, as a notice: taking this card from that session unless its lease is renewed. It waits two minutes and reads the lease again. Renewed means back off. Unchanged means stake as usual.
- **What it needs from the holder**: its timer reads the card once a minute for a notice, and renews at once when it sees one. Reading is cheap, and renewal stays at every 15 minutes otherwise.
- **The case it fixes**: a live holder whose lease only looks lapsed, because the clock ran behind or a renewal was lost. Q14 left that to be caught after the fact, at up to 15 minutes of double work. With a notice the takeover does not happen.
- **What it costs**: two minutes on every takeover. Takeovers follow a crash, so they are rare.
- **What it does not fix**: a holder whose session is alive and whose timer died. Nothing is listening, so the takeover goes ahead and the holder never learns. That gap exists today as well. It would close if every script that writes a card checked the lease first.
- **Effect on Q15**: it ruled takeover "at once". Choosing the notice supersedes that ADR with a new one, and Q15's card stays as it is.
