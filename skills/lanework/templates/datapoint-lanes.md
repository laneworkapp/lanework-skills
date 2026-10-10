# Datapoint lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The map: what the record is, where values are pushed, the limits. An agent keeps it current. |
| 2048 | Ideas | | What is not a datapoint yet. The owner decides which become datapoints; agents leave ideas here but never promote one. An idea about an existing value is a comment on its card, never a new card. |
| 3072 | Drafting | | The body is ahead of the file: the value is still being written. An agent drafts it once the owner places the card; a card drops back here when its body changes. |
| 4096 | Filed | | The body matches the file in the repository; the live system does not have it yet. An agent files it in the same commit that writes the file, then waits for the owner to push. |
| 5120 | Pushed | | The live system holds exactly what the body says, read back. The owner pushes; an agent moves the card here only after a read-back that agrees. |
