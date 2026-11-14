---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:40:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:40:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: 44e21920-ebf4-461d-8ab4-fa5e68e72525
---
**The timer is a small background shell loop, a process separate from the agent. It exists because an agent can read the clock at any time, and can only act on it when it takes a turn.**

- **You are right about the clock**: any agent can run `date` and subtract a start time. Measuring time was never the problem.
- **The problem is acting on it**: an agent does something only when it takes a turn. While it waits on a 40-minute build, or sits idle until you type, it takes no turn. Nothing wakes it at minute 15 to renew, so its lease would lapse mid-work.
- **What the timer is**: a loop the lease script starts in the background when it stakes, roughly "sleep a minute, look for a takeover notice, and every 15th minute rewrite `until`". It keeps running while the agent is busy or silent. Release stops it.
- **Why it counts sleeps and does not read the clock**: Q14. A loop that counts its own waiting is not fooled by a clock that jumps.
- **Its own stop rule**: the loop must exit when its session's process is gone. A loop that outlived a dead session would renew that session's lease forever, and the card would never free up.
- **What "the timer died" means**: that background process was killed while the session lives on. The harness cleaning up background shells, or a session resumed after a restart, could do it. Not measured: how often that happens.
- **The alternative without a timer**: the agent renews only when it acts, checking the clock as you describe. It is simpler, with no background process. A lease then lapses during any quiet stretch longer than its length, and no holder hears a takeover notice while quiet. Q4 chose the timer over this.
- **Word used loosely until now**: "timer" was never defined on this board. It goes into the glossary at the round's close.
