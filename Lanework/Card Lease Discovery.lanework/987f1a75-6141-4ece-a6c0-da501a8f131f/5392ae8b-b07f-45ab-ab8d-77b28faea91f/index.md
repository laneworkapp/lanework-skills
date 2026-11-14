---
schema: 1
kind: card
title: "Discovery map"
order: 2048
icon: {glyph: point.3.connected.trianglepath.dotted}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:03:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Every decision in the problem and domain space, grouped by corner. ✅ settled: one-line ruling, card linked. 💬 on the frontier: card linked. ⏳ not yet askable: what it waits on.

- **Problem**
  - ✅ A START comment never ends and a lane move names no holder, so a lease is wanted (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **People**
  - ⏳ How the owner sees a lease and frees one by hand (waits on Q8)
- **Domain**
  - ✅ The lease is `claimed: {by, until}` in card frontmatter ([Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1))
    - ✅ The holder is the stamp's `by` with the harness session id required [Q1](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb)
      - ✅ The session holds; its subagents never stake [Q7](lanework://33527992-d72c-417b-85a2-1b62bea96794/144897f2-11a2-4147-b862-579adf7dc6c9)
- **Scope**
  - ✅ One machine; across machines a lease is a hint [Q2](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894)
  - ✅ Every skill that starts work takes a lease; START shrinks to a short plan [Q5](lanework://33527992-d72c-417b-85a2-1b62bea96794/69b77f01-fcab-4737-8892-31c7ecaadd3c)
  - 💬 plan's Working lane beside the lease [Q10](lanework://33527992-d72c-417b-85a2-1b62bea96794/65be9ca2-633e-4ec9-8591-ff7ff12adea7)
- **Behavior**
  - ✅ Staking: write, wait, read back, provisionally [Q3](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb)
  - ✅ 30 minutes, renewed by a timer when under 15 remain [Q4](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665)
    - 💬 A lost lease and the work in flight [Q9](lanework://33527992-d72c-417b-85a2-1b62bea96794/35121e2d-eeed-440f-8364-a1637eb028c2)
      - ⏳ Taking over a card whose lease lapsed (waits on Q8, Q9)
        - ⏳ A handshake between agents: asked only if the two above show a need
  - 💬 Releasing a lease [Q8](lanework://33527992-d72c-417b-85a2-1b62bea96794/0f36b65c-b027-461a-b9af-5c8db6e5fc5a)
- **Constraints**
  - ✅ Cooperative: honored by agents, enforced by nothing (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **Architecture**
  - 💬 Where the lease mechanism lives [Q11](lanework://33527992-d72c-417b-85a2-1b62bea96794/5da76e6f-2a5e-449d-89e3-821636bc9b8c)
- **Integrations**
  - ⏳ The app with a card open: can a rewrite undo a renewal (waits on a test, [Fact](lanework://33527992-d72c-417b-85a2-1b62bea96794/674796c1-5068-49f7-ae1b-9a0c240e7e0a))
  - ✅ Merge: no special rule, the later `modified` stamp wins [Q6](lanework://33527992-d72c-417b-85a2-1b62bea96794/3182fff4-99d4-4d9f-8a8c-12926e6153c5)
- **Data**
  - 💬 What a lease write restamps and commits [Q12](lanework://33527992-d72c-417b-85a2-1b62bea96794/02c2d5fd-525b-46ef-af5f-3eee6e226566)
- **Risks**
  - ⏳ A slow holder taken for dead (waits on Q9)
  - 💬 A wrong clock in `until` [Q13](lanework://33527992-d72c-417b-85a2-1b62bea96794/df0483a6-4636-464f-b31c-83fa219e9eea)
- **Success**
  - ⏳ How the lease is judged to work (waits on the Behavior branch)
