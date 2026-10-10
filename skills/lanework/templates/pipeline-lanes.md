# Pipeline lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `icon`: the lane's `icon` mapping as written, or empty; tint only where it says what the glyph can't (`references/writes.md` § Icons, colors). `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | icon | body |
|---|---|---|---|---|
| 1024 | Ideas | | {glyph: lightbulb} | The inbox and triage queue; a one-line card is fine. The owner moves each card on to Shaping, or out. |
| 1536 | Issues | | {glyph: exclamationmark.triangle, color: carnation} | Something broken in the running system. It waits here until the owner moves it on. |
| 1792 | Tasks | | {glyph: checklist} | Small, clear chores that need no shaping. Each waits here until the owner moves it to Approved. Agents file the chores they find in Ideas, never here. |
| 2048 | Shaping | | {glyph: pencil.and.ruler} | Where the owner puts a card to be shaped. An agent develops it into a proposal with scope, risks and a recommendation, and moves it to Proposed once its open questions are answered. |
| 3072 | Proposed | | {glyph: hand.raised, color: smokey-tangerine} | The review gate. The owner approves each card, bounces it to Shaping, or rejects it; agents only move finished proposals in. |
| 4096 | Approved | | {glyph: checkmark.seal} | The build queue, top first. Approval is the go-ahead: an agent takes the top card into Active unasked. The spec is frozen: a scope change bounces the card to Shaping. |
| 5120 | Active | | {glyph: hammer} | Work in progress. An agent moves a card in as it starts, claiming it with a comment naming the session and branch, and moves it to Done when its done-when is met. |
| 6144 | Done | | {glyph: checkmark.circle} | Shipped work. The agent that built a card moves it in, with a closing comment carrying the evidence. |
