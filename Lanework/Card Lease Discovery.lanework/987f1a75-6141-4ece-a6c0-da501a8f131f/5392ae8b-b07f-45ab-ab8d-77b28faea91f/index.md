---
schema: 1
kind: card
title: "Discovery map"
order: 2048
icon: {glyph: point.3.connected.trianglepath.dotted}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
Every decision in the problem and domain space, grouped by corner. ✅ settled: one-line ruling, card linked. 💬 on the frontier: card linked. ⏳ not yet askable: what it waits on.

- **Problem**
  - ✅ A START comment never ends and a lane move names no holder, so a lease is wanted (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **People**
  - ⏳ How the owner sees a lease and frees one by hand (waits on release)
- **Domain**
  - ✅ The lease is `claimed: {by, until}` in card frontmatter ([Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1))
    - 💬 What identifies a lease's holder [Q1](lanework://33527992-d72c-417b-85a2-1b62bea96794/e150b8c1-ab33-44fb-9ee7-cc171c235abb)
- **Scope**
  - 💬 One machine or several [Q2](lanework://33527992-d72c-417b-85a2-1b62bea96794/73f4178e-0830-49d4-be12-8d6c41c60894)
  - ⏳ Which skills honor it, and whether the START comment stays beside it (waits on Q1)
  - ⏳ plan's Working lane beside the lease (waits on staking)
- **Behavior**
  - ⏳ Staking a claim when two agents reach for one card (waits on Q1, Q2)
  - ⏳ Lease length and renewal (waits on Q1); takes up [Q14 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3)
    - ⏳ A holder finds its lease lost (waits on renewal)
      - ⏳ Taking over a card whose lease lapsed (waits on the lost lease)
        - ⏳ A handshake between agents: asked only if the two above show a need
  - ⏳ Release when the work ends (waits on staking)
- **Constraints**
  - ✅ Cooperative: honored by agents, enforced by nothing (owner, chat 2026-11-13, [Topic](lanework://33527992-d72c-417b-85a2-1b62bea96794/468b5a06-2878-4141-a023-bcbdfdcd2a21))
- **Architecture**
  - ⏳ Where the mechanism lives and what writes the key (waits on staking)
- **Integrations**
  - ⏳ The app with a card open: can a rewrite undo a renewal (waits on a test, [Fact](lanework://33527992-d72c-417b-85a2-1b62bea96794/674796c1-5068-49f7-ae1b-9a0c240e7e0a))
  - ⏳ The `merge` skill's rule for two differing leases (waits on Q2)
- **Data**
  - ⏳ What a lease change restamps and commits (waits on staking)
- **Risks**
  - ⏳ A slow holder taken for dead (waits on the lost lease)
  - ⏳ A wrong clock in `until` (waits on renewal)
- **Success**
  - ⏳ How the lease is judged to work (waits on the Behavior branch)
