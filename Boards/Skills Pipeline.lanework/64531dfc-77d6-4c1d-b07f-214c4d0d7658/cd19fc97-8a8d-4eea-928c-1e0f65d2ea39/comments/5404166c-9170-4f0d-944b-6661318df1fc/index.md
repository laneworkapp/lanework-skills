---
schema: 1
kind: comment
created:  {at: 2026-11-21T12:06:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-21T12:06:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**The cause in the body is corrected: the lead's own frontmatter snippet hard-coded the block shape, not the grouped-lane rule in `sweep.md`.**

- **Source**: the Lanework Main session read the lead's transcript (session `fd84bd6f`). Its shaping snippet appends `labels:` over a one-entry block, and its filing heredoc reuses the block it needs for two-label cards.
- **Contributing**: a line in that lead's own handoff notes says to copy only the `labels:` block from another card, which copies layout with the value.
- **Checked here**: 0.8.0 ships `post-comment.sh` and the two lints but no card writer. `file-card.sh` is on `main` only and writes lane-default labels alone. The compact-form rule is in `writes.md` in 0.8.0 already.
- **Not checked here**: the transcript itself.
- **Changed**: Problem, Direction and Done when rewritten around the missing label writer.
