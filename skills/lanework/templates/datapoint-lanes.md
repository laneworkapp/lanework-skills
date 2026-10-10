# Datapoint lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. The second sentence of a body names who acts on the lane and what starts it; `heal/scripts/heal-descriptors.py` reads it, and the table of lane actors is `references/board-kinds.md`.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The map: what the record is, where the values are pushed, and what the limits are. An agent keeps it current as the record changes. |
| 2048 | Ideas | | What is not a card yet. Agents file ideas here unasked, and the owner decides which become cards. An idea about an existing value is a comment on its card, never a new card. |
| 3072 | Drafting | | The body is ahead of the file: the value is still being written. An agent drafts it here unasked, and a card drops back here the moment its body changes. |
| 4096 | Filed | | The body matches the file in the repository, and the live system does not have it yet. An agent files a card here in the same commit that writes the file, then waits for the owner to push. |
| 5120 | Pushed | | The live system holds exactly what the body says, verified by reading it back. The owner pushes, and an agent moves the card here only after a read-back that agrees. |
