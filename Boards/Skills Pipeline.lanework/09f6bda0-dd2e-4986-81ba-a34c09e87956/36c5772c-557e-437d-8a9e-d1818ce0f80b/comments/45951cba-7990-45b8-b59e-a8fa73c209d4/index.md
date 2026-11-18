---
schema: 1
kind: comment
in-reply-to: 6702494f-da92-4b3e-8ac3-fe81243cd68d
created:  {at: 2026-11-18T10:55:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Recap: the trial's checker can miss two kinds of trouble, and the question is whether to close either gap before the trial starts.**

**What the trial is.** You ruled that the lease counts as working once 50 leased cards have run with no trouble. The lint is the checker that reads the boards afterwards and counts trouble of three kinds:

- **Lease lost**: a session found that another session had taken its card. This is the direct sign of a collision, and the checker counts it reliably.
- **Two STARTs**: two different sessions each announced a plan on the same card within 30 minutes.
- **Lapsed**: a card still marked as held by a session that stopped renewing.

**Gap 1, in "two STARTs".** The checker tells sessions apart by the name each one signs its comments with. Most sessions in this repo sign with the same name, and a quarter of the START comments carry no session name. So two real sessions under one name never count as two, and this number will read 0 here whatever happens. It can also err the other way: a lead and its helper signing with different names would count as a collision on a single lease.

**Gap 2, in "lapsed".** The checker only sees a stale mark that is still on the card when it runs. If a session died and another session later took the card over, the mark is gone. A takeover note stays in the thread, and the checker does not count it. So a card that sat held by a dead session can pass unseen.

**The choices.**

- **A**: close gap 2 by counting takeover notes. Leave gap 1 open and say so in the trial's result. A small change to this card.
- **B**: change nothing. The trial's result names both gaps.
- **C**: A, and also close gap 1: every START carries the real id of the session holding the lease. That touches how every skill posts its START, so it is a new card.

**What I would pick: A.** A real collision already shows up as a lease-lost record, so gap 1 mostly hides a second, weaker signal. Gap 2 hides the one failure your ruling names outright, a card left held by a dead session, and closing it is cheap.

**Timing.** Nothing is blocked today. The trial starts with the first lease after 0.9.0 is released.
