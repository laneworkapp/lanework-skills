# Authority

Before any write, read in order:

1. **`<board>/CLAUDE.md`** (twin `AGENTS.md`): app-maintained guide, the complete current spec (layout, frontmatter, stamps, create/move/trash, attachments, comments, mentions, git). Never edit it. Never trust a remembered version over today's file.
2. **Board `index.md` body**: below the first `##` = owner's instruction sheet (repo facts, what "verified" means, blast radius, card bars).
3. **Each lane's `index.md` body**: entry/exit policy, and whether the lane is out of scope for agents. Read before filing into or moving out of it.

Lower layers refine, never override. Skills sit below all three: board files win.

Exception: a new board has no guide until its first open. Until then `founding.md` is the authority.

Versions: `lanework-agent-guide vN` on line 1 of `CLAUDE.md`, `lanework-schema vN` on line 1 of `.schema/VERSION`. Guide newer than a skill → guide right, skill out of date.
