# Design loop lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`. The second sentence of a body names who acts on the lane and what starts it; `heal/scripts/heal-descriptors.py` reads it, and the table of lane actors is `references/board-kinds.md`.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The standing reference: the inventory, the constraints, the evidence, and the calls still open. An agent keeps it current as evidence and rulings come in, and the owner rules the open calls. |
| 2048 | Alternatives | | One candidate direction per card, as a paragraph and its reasoning. Agents move cards on to Mockups when there is something to draw. |
| 3072 | Mockups | | Drawn directions. An agent draws a card that lands here, attaching renders, light and dark, for every variant it lists. A card that shows no picture is not in Mockups. |
| 4096 | Sittings | | The owner has walked the card. An agent records the rulings on it in the owner's words, and a card can loop back to Mockups. Only happens with the owner present. |
| 5120 | Chosen | | The direction that won. Only the owner chooses, and an agent then files it as build cards on a pipeline board, linked both ways. |
| 6144 | Dead ends | yes | Directions that died, one line each saying why. An agent files a direction here once the owner rules it out. Collapsed because it is read least and regretted most when lost. |
