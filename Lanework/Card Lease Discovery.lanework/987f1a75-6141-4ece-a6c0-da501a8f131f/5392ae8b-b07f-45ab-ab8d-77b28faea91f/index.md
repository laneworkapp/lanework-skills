---
schema: 1
kind: card
title: "Discovery map"
order: 2048
icon: {glyph: point.3.connected.trianglepath.dotted}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T13:46:17Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
Every decision in the problem and domain space, grouped by corner. ✅ settled: one-line ruling, card linked. 💬 on the frontier: card linked. ⏳ not yet askable: what it waits on.

- **Problem**
  - ✅ A START comment never ends and a lane move names no holder, so a lease is wanted (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **People**
  - ⏳ How the owner sees a lease and frees one by hand (waits on release)
- **Domain**
  - ✅ The lease is `claimed: {by, until}` in card frontmatter ([Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1))
    - ✅ The holder is the stamp's `by` with the harness session id required [Q1](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb)
      - 💬 A subagent shares its session's id: who holds [Q7](lanework://33527992-d72c-417b-85a2-1b62bea96794/144897f2-11a2-4147-b862-579adf7dc6c9) ([Fact](lanework://33527992-d72c-417b-85a2-1b62bea96794/e3ffb17b-9813-4861-ab7c-012899af2742))
- **Scope**
  - ✅ One machine; across machines a lease is a hint [Q2](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894)
  - 💬 Which skills take a lease, and the START comment [Q5](lanework://33527992-d72c-417b-85a2-1b62bea96794/69b77f01-fcab-4737-8892-31c7ecaadd3c)
  - ⏳ plan's Working lane beside the lease (waits on Q3)
- **Behavior**
  - 💬 Staking a lease on a free card [Q3](lanework://33527992-d72c-417b-85a2-1b62bea96794/f1733254-91fb-416a-bfab-42d0165d20cb)
  - 💬 Lease length and renewal [Q4](lanework://33527992-d72c-417b-85a2-1b62bea96794/7d91feb9-54cf-4b67-b95d-b657225e9665); takes up [Q14 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3)
    - ⏳ A holder finds its lease lost (waits on Q4)
      - ⏳ Taking over a card whose lease lapsed (waits on the lost lease)
        - ⏳ A handshake between agents: asked only if the two above show a need
  - ⏳ Release when the work ends (waits on Q3)
- **Constraints**
  - ✅ Cooperative: honored by agents, enforced by nothing (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **Architecture**
  - ⏳ Where the mechanism lives and what writes the key (waits on Q3)
- **Integrations**
  - ⏳ The app with a card open: can a rewrite undo a renewal (waits on a test, [Fact](lanework://33527992-d72c-417b-85a2-1b62bea96794/674796c1-5068-49f7-ae1b-9a0c240e7e0a))
  - 💬 The `merge` skill's rule for two differing leases [Q6](lanework://33527992-d72c-417b-85a2-1b62bea96794/3182fff4-99d4-4d9f-8a8c-12926e6153c5)
- **Data**
  - ⏳ What a lease change restamps and commits (waits on Q3, Q4)
- **Risks**
  - ⏳ A slow holder taken for dead (waits on the lost lease)
  - ⏳ A wrong clock in `until` (waits on Q4)
- **Success**
  - ⏳ How the lease is judged to work (waits on the Behavior branch)
