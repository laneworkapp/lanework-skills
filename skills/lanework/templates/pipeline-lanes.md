# Pipeline lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. The second sentence of a body names who acts on the lane and what starts it; `heal/scripts/heal-descriptors.py` reads it, and the table of lane actors is `references/board-kinds.md`.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Ideas | | The inbox and the triage queue. The owner triages: each card moves on to Shaping, or out, and agents file here but never move a card out. Zero bar to entry, a one-line card is fine. |
| 1536 | Issues | | The side entrance for something broken in the running system. An agent diagnoses and shapes a new issue where it sits, then moves it on to Proposed for review, skipping triage. |
| 1792 | Tasks | | The owner's side entrance for small, clear chores. A card the owner files here is already approved, so an agent builds it straight through Active without waiting to be asked. Agents file the chores they find in Ideas, never here. |
| 2048 | Shaping | | The agent work lane. An agent develops a card that lands here into a proposal, unasked, with scope, constraints, risks and a recommendation in the body. Once the proposal is finished and its open questions are answered, the agent moves it to Proposed. |
| 3072 | Proposed | | The human review gate. The owner reviews each card here: approve it, bounce it to Shaping, or reject it. The agent moves a finished proposal in, and agents never move a card out of this lane. |
| 4096 | Approved | | The ready-to-build queue, ranked in build order, top is next. Approving a card is the go-ahead: an agent takes the top card into Active without waiting to be asked. The spec is frozen, so a scope change bounces the card back to Shaping. |
| 5120 | Active | | The build lane. An agent builds the card it claims from Approved or Tasks, and moves it to Done when its done-when is met. One session holds a card at a time, claiming it with a comment naming the session and the branch. |
| 6144 | Done | | Shipped work. The agent that built a card moves it in when its done-when is met, with a closing comment carrying the evidence. |
