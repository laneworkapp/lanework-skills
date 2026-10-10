# Pipeline lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Ideas | | The inbox and the triage queue. The owner triages each card on to Shaping, or out, and agents here may read, link, research and answer, but start work or move a card out only when the owner explicitly asks. Agents file here, and a one-line card is fine. |
| 1536 | Issues | | The side entrance for something broken in the running system. Agents here may read, link, research and answer, but start work or move a card out only when the owner explicitly asks. |
| 1792 | Tasks | | The owner's side entrance for small, clear chores. The owner moves a chore to Approved, and agents here may read, link, research and answer, but start work only when the owner explicitly asks. Agents file the chores they find in Ideas, never here. |
| 2048 | Shaping | | The agent work lane. The owner places a card here for an agent to develop, unasked, into a proposal with scope, constraints, risks and a recommendation. Once it is finished and its open questions are answered, the agent moves it to Proposed. |
| 3072 | Proposed | | The human review gate. The owner reviews each card here: approve it, bounce it to Shaping, or reject it. The agent moves a finished proposal in, and agents never move a card out of this lane. |
| 4096 | Approved | | The ready-to-build queue, ranked in build order, top is next. Approving a card is the go-ahead: an agent takes the top card into Active without waiting to be asked. The spec is frozen, so a scope change bounces the card back to Shaping. |
| 5120 | Active | | The build lane. An agent moves a card in as it starts, and to Done when its done-when is met. One session holds a card at a time, claiming it with a comment naming the session and the branch. |
| 6144 | Done | | Shipped work. The agent that built a card moves it in when its done-when is met, with a closing comment carrying the evidence. |
