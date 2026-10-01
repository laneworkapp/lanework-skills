# Pipeline lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Ideas | | The inbox and the triage queue. Zero bar to entry, a one-line card is fine. Triage moves each card on to Shaping, or out. |
| 1536 | Issues | | The side entrance for something broken in the running system. An issue skips triage and is shaped or fixed on its own merit. |
| 1792 | Tasks | | The owner's side entrance for small, clear chores. A card the owner files here is already approved, so it is built straight through Active. Agents file the chores they find in Ideas, never here. |
| 2048 | Shaping | | The agent work lane. A raw idea is developed here into a proposal with scope, constraints, risks and a recommendation in the body. |
| 3072 | Proposed | | The human review gate. The proposal is finished and waiting on the owner. Agents never move a card out of this lane. |
| 4096 | Approved | | The ready-to-build queue, ranked in build order, top is next. The spec is frozen, so a scope change bounces the card back to Shaping. |
| 5120 | Active | | The build lane. One session holds a card at a time, claiming it with a comment naming the session and the branch. |
| 6144 | Done | | Shipped work. A card arrives when its done-when is met, with a closing comment carrying the evidence. |
