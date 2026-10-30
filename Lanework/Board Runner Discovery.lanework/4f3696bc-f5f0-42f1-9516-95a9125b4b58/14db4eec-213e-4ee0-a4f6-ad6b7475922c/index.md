---
schema: 1
kind: card
title: "Discovery map"
order: 2048
icon: {glyph: point.3.connected.trianglepath.dotted}
created:  {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Every decision in the problem and domain space, grouped by corner. ✅ settled: one-line ruling, card linked. ❓ on the frontier: card linked. ◦ not yet askable: what it waits on.

- **Problem**
  - ✅ Continuous agents on a board, flat context, no session in the loop; live reasoning given up (owner, 2026-10-30, Topic card)
- **Scope**
  - ❓ [Q1: Phase 1 scope](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74)
    - ◦ Build trust gate: only cards a human moved into Approved (waits on Q1)
- **Behavior**
  - ❓ [Q2: Where lane rules come from](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/40de41da-04d2-4980-b6b3-cfd4fb5a1c72)
  - ❓ [Q3: What starts a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1237c522-b375-407b-b9f7-13dc79b28cfd)
  - ❓ [Q5: Fresh job or resumed session](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/25fe03a3-f47b-4929-934b-e575d7ca7383)
  - ◦ Pause the runner, stop one card (waits on Q1, Q3)
  - ◦ Failure: no retry loop, turn and budget caps, what a failed job leaves on the card (waits on Q1)
- **Architecture**
  - ❓ [Q4: One board or many per runner](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/08f2ee0c-c072-4233-b4a2-60841345b416)
  - ❓ [Q6: How a card shows it is taken](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1)
  - ◦ Worktree isolation for builds (waits on Q1)
- **Constraints**
  - ◦ Unattended permission mode and allowlist (waits on Q1)
  - ◦ Concurrency cap and memory pressure (waits on Q1, Q4)
- **Data**
  - ❓ [Q8: What the owner sees of a job](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7eb05b54-d522-4a92-a4ea-8371161aced5)
- **Integrations**
  - ◦ Install: launchd plist, terminal, or both; auth token (waits on Q4)
  - ◦ App launch via NSUserUnixTask: out of scope, later phase (Topic card)
- **Domain**
  - ◦ Glossary: runner, job, trigger (pinned as rulings name them)
- **Risks**
  - ◦ Prompt injection from card bodies (waits on Q1)
  - ◦ Runner triggering itself on its own writes (waits on Q3)
- **Success**
  - ❓ [Q7: What counts as success](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/30ab959c-6258-462a-932b-05c7261d7067)
