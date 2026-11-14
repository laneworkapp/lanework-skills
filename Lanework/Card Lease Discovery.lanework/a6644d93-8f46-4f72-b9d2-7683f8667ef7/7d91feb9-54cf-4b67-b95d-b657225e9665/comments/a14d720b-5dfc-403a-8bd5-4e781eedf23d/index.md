---
schema: 1
kind: comment
created:  {at: 2026-11-14T13:49:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T13:49:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
in-reply-to: adb79ade-585a-4162-a06e-5525b68d5ff4
---
**An estimated first lease helps only when the holder cannot renew in time, and that case has a cheaper fix.**

- **Recorded from the owner's comment**: 30 minutes "sounds right", and renewing with 15 minutes left "sounds right". The open part is whether the first lease is sized to the expected work.
- **While the holder lives**: renewal keeps the lease whatever its first length, so an estimate changes nothing.
- **When the holder dies**: the card stays taken until `until`. A 2-hour estimate leaves a dead build's card held for up to 2 hours, against 30 minutes with a fixed length. A longer estimate only lengthens that wait.
- **Where an estimate does help**: one long blocking command, such as a 40-minute build. The agent cannot renew while it waits on the command, so a fixed 30-minute lease would lapse mid-build.
- **Cheaper fix for that case**: renew on a timer, from a background loop started with the lease, rather than at the agent's next write. Every lease then stays at 30 minutes, and an agent never has to guess its workload.
- **Options now**: A, 30 minutes fixed, renewed when under 15 remain, by a timer while the work runs. B, the first lease sized to the agent's estimate (never under 30 minutes), then renewed the same way.
