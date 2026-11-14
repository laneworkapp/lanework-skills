---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:46:47Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:46:47Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Discovery is at its end: 22 questions settled, none parked, and the frontier is empty.**

**What was agreed.** A lease is the `claimed: {by, until}` key on a card, held by a session and named by its harness session id; a session's subagents work under its leases and never stake. It holds on one machine and is only a hint across machines. Every skill that starts work stakes one through a single lanework script: write, wait a second, read back. The lease runs 30 minutes, and a background loop called the timer renews it every 15 minutes of elapsed time and reads the card each minute for a takeover notice. A holder releases in its closing write. A holder that finds another session's `by` stops, records the loss and leaves its work in place. A lapsed lease is taken over after a notice and a two-minute wait, which a live holder answers by renewing. A lease more than 35 minutes ahead of now is no lease. Every card-writing script checks the lease first, which covers a dead timer. The owner sees leases through agents and reports. It counts as working when smoke passes and the first 50 leased cards run clean.

**Records, 14 in force and 1 superseded.**

- [ADR: A lease's holder is the stamp's by, with the harness session id required](lanework://33527992-d72c-417b-85a2-1b62bea96794/31f5a0e4-1c31-43be-a36f-5fedd78a3bc9)
- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: A lease holds on one machine; across machines it is a hint](lanework://33527992-d72c-417b-85a2-1b62bea96794/94e3d45e-37cf-4c39-a633-87610ab297b4)
- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
- [ADR: A lease runs 30 minutes, renewed by a timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/ce03dec0-06e0-4fa8-ac29-671c59ba6930)
- [ADR: A lost lease leaves the work in place, and the loser stops](lanework://33527992-d72c-417b-85a2-1b62bea96794/3b8d6e0b-1668-4e67-80ab-4a88fda8ad96)
- [ADR: A takeover posts a notice and waits two minutes](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b)
- [ADR: The clock guard is a range check against now, with an elapsed-time timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/674f3c98-33a5-41f5-acb3-7f59abafdfcf)
- [ADR: Every card-writing script checks the lease first](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)
- [ADR: One lanework script holds the lease mechanism and its timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/0e5b4553-6ac0-47b9-862b-91951dc35948)
- [ADR: A lease write restamps modified and is never committed alone](lanework://33527992-d72c-417b-85a2-1b62bea96794/aec193e9-55d2-4f60-9cd6-17a05258e307)
- [PDR: Leases are seen through agents and reports, not on the board](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)
- [PDR: The lease works when smoke passes and 50 leased cards run clean](lanework://33527992-d72c-417b-85a2-1b62bea96794/67912ed8-4595-4514-8a6f-a5a629b473c8)
- Superseded: [ADR: A lapsed lease is taken over at once, with a record](lanework://33527992-d72c-417b-85a2-1b62bea96794/9a6850de-9571-4e7c-bacd-d0758a2bfa08)

**Glossary**, in `CONTEXT.md`: Lease, Holder, Timer, Renewal, Lapsed lease, Takeover, Takeover notice.

**Left open on purpose.**

- Staking is provisional: one recorded collision reopens it, with a lock as the fallback.
- The app rewriting an open card is untested, and is tested in the build.
- A clock running behind is not guarded. The takeover notice covers it.
- Not measured: how often a timer dies while its session lives.
- [Q14 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3) asks the same as Q4 here and is still open on that board.

**Nothing is built and no work card is filed** until the owner confirms.
