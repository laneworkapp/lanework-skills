---
schema: 1
kind: card
title: "Discovery map"
order: 2048
icon: {glyph: point.3.connected.trianglepath.dotted}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Map
---
Every decision in the problem and domain space, grouped by corner. ✅ settled: one-line ruling, card linked. 💬 on the frontier: card linked. ⏳ not yet askable: what it waits on.

- **Problem**
  - ✅ A START comment never ends and a lane move names no holder, so a lease is wanted (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **People**
  - ✅ The owner sees leases through agents and reports, and frees one by deleting the line or telling an agent [Q17](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e173c4d-4af0-4b1a-b54d-c370ddf8a10f)
- **Domain**
  - ✅ The lease is `claimed: {by, until}` in card frontmatter ([Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1))
    - ✅ The holder is the stamp's `by` with the harness session id required [Q1](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb)
      - ✅ The session holds; its subagents never stake [Q7](lanework://33527992-d72c-417b-85a2-1b62bea96794/144897f2-11a2-4147-b862-579adf7dc6c9)
    - ✅ The background loop that renews and listens is called the timer [Q22](lanework://33527992-d72c-417b-85a2-1b62bea96794/bd7f1521-b626-4201-baec-ac7797347f30)
- **Scope**
  - ✅ One machine; across machines a lease is a hint [Q2](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894)
  - ✅ Every skill that starts work takes a lease; START shrinks to a short plan [Q5](lanework://33527992-d72c-417b-85a2-1b62bea96794/69b77f01-fcab-4737-8892-31c7ecaadd3c)
  - ✅ plan stakes a lease and still moves the ticket to Working [Q10](lanework://33527992-d72c-417b-85a2-1b62bea96794/65be9ca2-633e-4ec9-8591-ff7ff12adea7)
- **Behavior**
  - ✅ Staking: write, wait, read back, provisionally [Q3](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb)
  - ✅ 30 minutes, renewed by a timer when under 15 remain [Q4](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665)
    - ✅ A lost lease: the work stays, named in the record, and the loser stops [Q9](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2)
      - ✅ A lapsed lease is taken over with a record [Q15](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53); "at once" superseded by Q18
        - ✅ A notice before takeover, a two-minute wait, and a live holder answers by renewing [Q18](lanework://33527992-d72c-417b-85a2-1b62bea96794/631144a9-bc7c-4238-9c2d-61fef80cca31)
  - ✅ Released when the holder stops working the card, in its closing write [Q8](lanework://33527992-d72c-417b-85a2-1b62bea96794/0f36b65c-b027-461a-b9af-5c8db6e5fc5a)
- **Constraints**
  - ✅ Cooperative: honored by agents, enforced by nothing (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **Architecture**
  - ✅ One lanework script holds stake, renew, check, release and the timer [Q11](lanework://33527992-d72c-417b-85a2-1b62bea96794/5da76e6f-2a5e-449d-89e3-821636bc9b8c)
- **Integrations**
  - ✅ The untested app rewrite: accepted for the design, tested in the build [Q19](lanework://33527992-d72c-417b-85a2-1b62bea96794/066be348-6145-4667-b4bc-8dc5bcae9eb6) ([Fact](lanework://33527992-d72c-417b-85a2-1b62bea96794/674796c1-5068-49f7-ae1b-9a0c240e7e0a))
  - ✅ Merge: no special rule, the later `modified` stamp wins [Q6](lanework://33527992-d72c-417b-85a2-1b62bea96794/3182fff4-99d4-4d9f-8a8c-12926e6153c5)
- **Data**
  - ✅ A lease write restamps `modified` and is never committed alone [Q12](lanework://33527992-d72c-417b-85a2-1b62bea96794/02c2d5fd-525b-46ef-af5f-3eee6e226566)
- **Risks**
  - ✅ A holder back late, nobody having taken the card, renews and carries on [Q16](lanework://33527992-d72c-417b-85a2-1b62bea96794/c8e5934d-298c-4444-88b2-b44dd8c7ce95)
  - ✅ A wrong clock: a guard is wanted [Q13](lanework://33527992-d72c-417b-85a2-1b62bea96794/df0483a6-4636-464f-b31c-83fa219e9eea)
    - ✅ The guard: `until` over 35 minutes ahead of now is no lease; the timer renews by elapsed time [Q14](lanework://33527992-d72c-417b-85a2-1b62bea96794/df8b2a68-f17a-444c-97c6-74fa972795c3)
  - ✅ A holder whose timer died: every card-writing script checks the lease first [Q21](lanework://33527992-d72c-417b-85a2-1b62bea96794/39811630-aa7b-410d-a181-f9ee942d0c77)
- **Success**
  - ✅ Smoke cases for every ruling, plus a clean trial over the first 50 leased cards [Q20](lanework://33527992-d72c-417b-85a2-1b62bea96794/536cb934-d63d-40c9-85dc-5819b6dd13d6)
