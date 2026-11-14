# Lanework agent skills

Skills that let Claude agents work Lanework boards: plain folders of Markdown that the Lanework app renders live.

## Language

**Runner**:
A resident process, owned by the `run` skill, that watches one board and starts a fresh headless Claude job for each change the board's lanes call for. No Claude session sits in its loop.
_Avoid_: daemon, worker, agent loop

**Job**:
One headless `claude -p` run that a runner starts on one card, doing its work through the `work` skill and then exiting.
_Avoid_: task, handler (a handler is dispatch's subagent)

**Lease**:
The `claimed: {by, until}` key in a card's frontmatter that marks the card as taken until the time it names, honored by runner jobs and interactive sessions alike.
_Avoid_: lock, claim comment (a START comment is a record, not a lease)

**Holder**:
The session that holds a lease, named in its `by` by the harness session id. A session's subagents work under its leases and are never holders themselves.
_Avoid_: owner (the owner is the human), claimant, lessee

**Timer**:
The background loop the lease script starts when a holder stakes, a process separate from the agent. It renews the lease, reads the card each minute for a takeover notice, and exits with its session. It counts its own waiting and does not read the clock.
_Avoid_: keeper, control loop, daemon, clock

**Renewal**:
A holder's rewrite of its own lease with a fresh `until`, made by its timer every 15 minutes of elapsed time for as long as the work runs.
_Avoid_: heartbeat, refresh, extend

**Lapsed lease**:
A lease whose `until` has passed without a release. The card is open to takeover.
_Avoid_: expired claim, stale lease, dead lease

**Takeover**:
A session staking a card whose lease lapsed under another holder, after a takeover notice went unanswered.
_Avoid_: steal, reclaim, preempt

**Takeover notice**:
The record a session posts before a takeover, naming the holder it is taking the card from. A live holder answers it by renewing, within two minutes.
_Avoid_: handshake, broadcast, ping

