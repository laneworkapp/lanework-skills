---
schema: 1
kind: comment
created:  {at: 2026-11-12T02:18:04Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T02:18:04Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Gate GREEN on `da5b1f8` (the final head; `210e485` is the minimum): `bash tests/smoke.sh`, run twice in a row, 156 passed both times, rc 0.**

**Evidence**: the final rebase onto origin/main `ff85eff`+ kept the two-commit split, README § Sizes recomputed with `wc -w` in each commit.
**Found by the gate**: the first gate run on `55836ff` passed (156) and the second failed in the post-comment cases: `ls .../<card>/comments: No such file or directory`. The case took the first card of the board, and in the full smoke that card can have no `comments/`. Fixed in `da5b1f8` (counting tolerates a missing `comments/`, the seed helper uses `mkdir -p`), and checked scoped with the card's `comments/` removed. Then two full runs on `da5b1f8`, both green.
