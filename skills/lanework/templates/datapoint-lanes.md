# Datapoint lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The map: what the record is, where the values are pushed, and what the limits are. An agent keeps it current as the record changes. |
| 2048 | Ideas | | What is not a datapoint yet. The owner decides which ideas become datapoints, and agents leave ideas here but never promote one. An idea about an existing value is a comment on its card, never a new card. |
| 3072 | Drafting | | The body is ahead of the file: the value is still being written. An agent drafts it here once the owner places the card, and a card drops back here the moment its body changes. |
| 4096 | Filed | | The body matches the file in the repository, and the live system does not have it yet. An agent files a card here in the same commit that writes the file, then waits for the owner to push. |
| 5120 | Pushed | | The live system holds exactly what the body says, verified by reading it back. The owner pushes, and an agent moves the card here only after a read-back that agrees. |
