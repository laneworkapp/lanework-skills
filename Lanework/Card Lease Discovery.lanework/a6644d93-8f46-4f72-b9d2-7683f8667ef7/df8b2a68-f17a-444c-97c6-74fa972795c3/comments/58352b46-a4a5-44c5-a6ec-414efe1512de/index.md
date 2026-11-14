---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:13:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:13:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: 55cb0aaa-c6f0-435b-822e-63b18e15a5ca
---
**Walk-through: A is the only check that compares the lease with something the wrong clock did not also write, and it needs one addition on the holder's side.**

**What a guard can compare `until` with.** A lease holds one time. A guard needs a second value to hold it against, and the choice of that value is the basis:

| basis | written by | so it catches |
|---|---|---|
| now, read at check time (A) | the clock as it is now | a lease written under a different clock than today's |
| the card's `modified.at` (B) | the same write as `until` | an `until` not written by the script |
| the file's time on disk (D) | any write to the file, by anyone | nothing reliably |

**A, the range check.** A lease is 30 minutes long, so an honest `until` is never more than 30 minutes ahead of now. The guard treats `until` over 35 minutes ahead as no lease.

- **Catches**: the clock was 3 hours ahead when a lease was written and is now right. Without a guard that card is held for 3 hours by a holder that may be dead. With A it is free at once. Also a hand-typed `until` far ahead, and a lease from another machine whose clock runs ahead.
- **Misses**: an error under 35 minutes, which costs at most 35 minutes. And the clock running behind, which makes a live lease look lapsed. Another agent then takes the card, and the holder finds out at its next renewal and stops (Q9). Cost: up to 15 minutes of double work.
- **Why 35 and not 30**: 5 minutes of slack, so a small clock step never voids an honest lease.
- **Its gap**: a live holder whose own lease was written under the wrong clock. Its timer sees hours left, so it would not renew, and so would not notice A voided its lease. The fix is the addition below.

**B, the stamp check.** `until` must be within 30 minutes of the card's `modified.at`.

- **Why it sounds right**: every lease write restamps `modified` (Q12), so the two always travel together.
- **Why it does little**: the script writes both from the same clock in the same write. If the clock is wrong, both are wrong together and B passes. B only catches an `until` written by something other than the script, such as a hand edit granting a 2-hour lease.
- **Its weak point**: it trusts `modified.at`, and agents have written wrong stamps on this very repo's boards before.

**C, both.** Catches what either catches. B adds one case to A (a hand-made long lease that is still under 35 minutes ahead of now), for a second rule every reader of a lease must apply.

**D, the file's time on disk.** It cannot be mis-typed, which is its one merit. A body edit in the app, a `git pull` or a checkout all reset it, so it would void honest leases and pass bad ones.

**The addition A needs.** The holder's timer renews every 15 minutes of elapsed time, counted by waiting, and never by comparing `until` with the clock. Each renewal rewrites `until` from the clock as it is then. So a lease written under a wrong clock repairs itself within 15 minutes, and the holder reads `by` on schedule whatever the clock did. In normal running this is the same as "renew when under 15 remain" (Q4).

**Where that leaves it**: A with the elapsed-time timer covers the long-held dead card and the live holder under a corrected clock. A clock running behind is left to the renewal read-back. B and D compare the lease with values the same faulty source produced.
