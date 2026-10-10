# Design loop lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The standing reference: inventory, constraints, evidence and open calls. An agent keeps it current, and the owner rules the open calls. |
| 2048 | Alternatives | | One candidate direction per card, as a paragraph and its reasoning. Agents move cards on to Mockups when there is something to draw. |
| 3072 | Mockups | | Drawn directions, with renders attached light and dark for every variant. An agent draws each card that lands here. |
| 4096 | Sittings | | A sitting: the owner walks the card, so the owner is present. An agent records the rulings in the owner's words, and the card may loop back to Mockups. |
| 5120 | Chosen | | The direction that won; only the owner chooses. An agent files build cards on a pipeline board, linked both ways, only when the owner asks. |
| 6144 | Dead ends | yes | Directions that died, one line each saying why. An agent files one here once the owner rules it out. |
