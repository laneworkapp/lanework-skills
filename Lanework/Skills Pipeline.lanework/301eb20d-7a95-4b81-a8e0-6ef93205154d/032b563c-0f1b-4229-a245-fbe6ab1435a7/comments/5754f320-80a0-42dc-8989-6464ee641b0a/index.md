---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:42:14Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:42:14Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Shaped and moved to Proposed.** No open call for the owner.

- **Decision**: one helper, `union_lane_defaults`, in `lanework/scripts/lib.sh`, importing `heal-board.py`'s label model (`flattened`, `definitions_of`, the `single-kind` pick) so the filers and the heal cannot disagree. Three callers; `file-question.sh` also needs its frontmatter staged and compacted.
- **Evidence**: grep finds no `card-defaults` in any script; the rule lives once at `writes.md:34`; `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh` and `found-*` are out (moves and lane founding, not births).
- **Nothing built, no file outside the board changed.**
