---
schema: 1
kind: comment
created:  {at: 2026-11-23T18:47:19Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T18:47:19Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: both delete cases are fixed and on main.**

- **Delete against an addition:** a card deleted on one side and given a comment, attachment or relation on the other is restored whole, staged, never committed. The report names it.
- **Delete against a bare move:** the card is kept where it was moved, `.trash/` included.
- **Found in review and fixed:** a card restored into a lane the other side removed went into a folder with no `index.md`. It now goes to the lane's trashed copy, else `.trash/<card>`. Board paths with `[`, `*` or `?` are now found in history.
- **Evidence:** each new `merge-case.sh` row fails on the old script and passes now. Full smoke on the final tree: 409 passed. Independent review, two passes: approved with nits.
- **Left out, filed in Issues:** [the lane hole on the conflict path](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0a7eecc5-0441-4ab5-b379-5cb971c592c3). The conflict path has the same lane hole, and a restore into the trash keeps its old stamp.
- **Limit:** when the pass runs after later commits, it restores the deleting side's last version, not the base. `rules.md` says so.
- **Commits on main:** `45acb355`, `df36ba65`.
- **CHANGELOG:** Merging a board no longer loses a card that one side deleted while the other moved it or added a comment, attachment or relation.
