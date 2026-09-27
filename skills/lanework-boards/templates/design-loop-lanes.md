# Design loop lanes

Read by `scripts/found-board.sh`. `collapsed`: `yes` starts collapsed. `body`: owner-facing lane policy, no `|`.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The standing reference: the inventory, the constraints, the evidence, and the calls still open. |
| 2048 | Alternatives | | One candidate direction per card, as a paragraph and its reasoning. Agents move cards on to Mockups when there is something to draw. |
| 3072 | Mockups | | Drawn directions. Renders are attached to the card, light and dark, for every variant it lists. A card that shows no picture is not in Mockups. |
| 4096 | Sittings | | The owner has walked the card. Rulings are recorded on it in the owner's words, and a card can loop back to Mockups. Only happens with the owner present. |
| 5120 | Chosen | | The direction that won. Only the owner chooses. It leaves as build cards on a pipeline board, linked both ways. |
| 6144 | Dead ends | yes | Directions that died, one line each saying why. Collapsed because it is read least and regretted most when lost. |
