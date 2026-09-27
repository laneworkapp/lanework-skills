# Reading

## Order

Lanes left → right by ascending `order`; cards top → bottom by `order` within a lane; missing `order` sorts last; ties by folder name.

## One pass

`scripts/read-board.sh <board>` prints every lane and card in that order, with short ids. Then read, in order: board body, lane bodies, the cards you care about.

## Rules

- **`cat` whole files, never `head -N`.** Truncated reads have missed owner rulings.
- **Read the whole thread before acting on a card**: `comments/<uuid>/index.md`, sorted by `created.at`. Body = what was believed at filing; thread = what's been learned since (duplicates, bundle-with, wrong root cause). Same for every card it links.
- Top-level scalars: `fm_value` in `scripts/lib.sh`. Nested keys: `yq` (mikefarah v4) over the frontmatter block:

```bash
fm() { awk '/^---$/{n++;next} n==1' "$1"; }
fm "$f" | yq -r '.created.by.kind // ""'
```
