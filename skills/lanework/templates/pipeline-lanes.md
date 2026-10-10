# Pipeline lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Ideas | | The inbox and triage queue; a one-line card is fine. The owner moves each card on to Shaping, or out. |
| 1536 | Issues | | Something broken in the running system. It waits here until the owner moves it on. |
| 1792 | Tasks | | Small, clear chores that need no shaping. Each waits here until the owner moves it to Approved. Agents file the chores they find in Ideas, never here. |
| 2048 | Shaping | | Where the owner puts a card to be shaped. An agent develops it into a proposal with scope, risks and a recommendation, and moves it to Proposed once its open questions are answered. |
| 3072 | Proposed | | The review gate. The owner approves each card, bounces it to Shaping, or rejects it; agents only move finished proposals in. |
| 4096 | Approved | | The build queue, top first. Approval is the go-ahead: an agent takes the top card into Active unasked. The spec is frozen: a scope change bounces the card to Shaping. |
| 5120 | Active | | Work in progress. An agent moves a card in as it starts, claiming it with a comment naming the session and branch, and moves it to Done when its done-when is met. |
| 6144 | Done | | Shipped work. The agent that built a card moves it in, with a closing comment carrying the evidence. |
