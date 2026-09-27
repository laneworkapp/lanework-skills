# Datapoint lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The map: what the record is, where the values are pushed, and what the limits are. |
| 2048 | Ideas | | What is not a card yet. An idea about an existing value is a comment on its card, never a new card. |
| 3072 | Drafting | | The body is ahead of the file: the value is still being written. A card drops back here the moment its body changes. |
| 4096 | Filed | | The body matches the file in the repository, and the live system does not have it yet. Filed in the same commit that writes the file. |
| 5120 | Pushed | | The live system holds exactly what the body says, verified by reading it back. Pushing is the owner's. |
