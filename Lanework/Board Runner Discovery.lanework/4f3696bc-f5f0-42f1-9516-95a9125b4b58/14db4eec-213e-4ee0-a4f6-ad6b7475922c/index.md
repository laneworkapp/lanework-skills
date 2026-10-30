---
schema: 1
kind: card
title: "Discovery map"
order: 2048
icon: {glyph: point.3.connected.trianglepath.dotted}
created:  {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T15:31:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Every decision in the problem and domain space, grouped by corner. ✅ settled: one-line ruling, card linked. ❓ on the frontier: card linked. ◦ not yet askable: what it waits on.

- **Problem**
  - ✅ Continuous agents on a board, flat context, no session in the loop; live reasoning given up (owner, 2026-10-30, Topic card)
- **Scope**
  - ✅ Phase 1 runs board-side jobs and builds [Q1](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74)
    - ❓ The build trust gate [Q11](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/059e0156-6ff8-4c87-86ab-d6c289bc0068)
  - ✅ If it succeeds, run displaces /watch and /dispatch [Q3](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1237c522-b375-407b-b9f7-13dc79b28cfd)
- **Behavior**
  - ✅ The run skill owns its trigger rules [Q3](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/1237c522-b375-407b-b9f7-13dc79b28cfd)
    - ❓ Which changes reach the lane reader [Q9](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/2bb6dc11-e6c8-4216-a0b6-658ffe1b5e00)
  - ✅ A small model reads the lane bodies to pick each job [Q2](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/40de41da-04d2-4980-b6b3-cfd4fb5a1c72)
    - ❓ The lane reader's model and output [Q10](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/b3d88696-ffdf-4730-b16c-9b18f0eea6c2)
  - ✅ Every job starts fresh; the board is the memory [Q5](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/25fe03a3-f47b-4929-934b-e575d7ca7383)
  - ❓ Pausing the runner, stopping a card [Q15](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/46519115-f307-4732-a58c-9d355bf2e715)
  - ❓ A failed job [Q16](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/e6fe8011-de18-49b9-970f-070cda99e83b)
- **Architecture**
  - ✅ One runner process per board [Q4](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/08f2ee0c-c072-4233-b4a2-60841345b416)
  - ✅ Jobs do their work through /lanework:work, worktrees included [Q1](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/01b88591-992f-4cb3-bd91-edff864d0b74)
  - ✅ A lease key in card frontmatter marks a taken card [Q6](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1)
    - ❓ Lease length and expiry [Q14](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3)
    - ◦ work skill honors the lease: follows from Q6, a build task, no question
- **Constraints**
  - ❓ Unattended permissions [Q12](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/f28e587b-02db-4cc0-8ae6-8311129e3a53)
  - ❓ Jobs running at once [Q13](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/c2abd8e2-24ec-462f-8268-37fb9ff17e77)
- **Data**
  - ✅ Jobs stream live to the terminal; no transcript kept [Q8](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/7eb05b54-d522-4a92-a4ea-8371161aced5)
- **Integrations**
  - ❓ How the runner starts [Q17](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/026b70bf-9164-4826-8edb-e45a0788ea1a)
  - ◦ App launch via NSUserUnixTask: out of scope, later phase (Topic card)
- **Domain**
  - ✅ Runner, Job, Lease pinned in CONTEXT.md
- **Risks**
  - ◦ Prompt injection from card text: narrowed by Q9 and Q11, revisit after them
  - ◦ Runner triggering itself: settled by Q9 if owner-only triggers hold
- **Success**
  - ✅ The owner judges by use [Q7](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/30ab959c-6258-462a-932b-05c7261d7067)
