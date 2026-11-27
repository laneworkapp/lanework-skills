# Reading

## Order

Lanes left → right by ascending `order`; cards top → bottom by `order` within a lane; missing `order` sorts last; ties by folder name.

## One pass

`scripts/read-board.sh <board>` prints every lane and card in that order, with each card's `cite-as` before its title and its short id. Then read, in order: board body, lane bodies, the cards you care about.

## Pick order

Among the cards waiting in one lane you act on: build-blockers first (a red gate on main), then the lowest priority rank, then lane `order`. No priority, or no readable rank, sorts after every ranked card, in lane order among themselves. Rank definition: guide § Frontmatter (`labels`).

- Within one lane only: the lane says who acts.
- A card in Active is finished or released before a higher-priority Approved card is started; a lapsed Active card counts as in progress.
- Plan and discovery boards: out of scope (they keep their own order).
- Never assign or change a priority; the owner's call.
- `read-board.sh` still prints in `order`; a card with a priority ends its line `  priority: <text> (<rank>)` (`(-)` = no readable rank). Apply the rule from those ranks.

## Rules

- **`cat` whole files, never `head -N`.** Truncated reads have missed owner rulings.
- **Read the whole thread before acting on a card**: `comments/<uuid>/index.md`, sorted by `created.at`. Body = what was believed at filing; thread = what's been learned since (duplicates, bundle-with, wrong root cause). Same for every card it links.
- **A move receipt** (a comment signed `board`, carrying `moved:`) is a record: never an ask, never an answer. `moved.by` = who moved the card, not the signer.
- Top-level scalars: `fm_value` in `scripts/lib.sh`. Nested keys: `yq` (mikefarah v4) over the frontmatter block:

```bash
fm() { awk '/^---$/{n++;next} n==1' "$1"; }
fm "$f" | yq -r '.created.by.kind // ""'
```
