---
schema: 1
kind: comment
created:  {at: 2026-11-21T16:45:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; to Proposed.

**Reproduced**: items 1 to 3, on throwaway boards. A tab in a card name made `lint-stamps.sh` print `0s ahead` for a stamp 597 s ahead. A lane symlinked to a sibling lane doubled every finding in all three lints.

**Proposal**: one escaping rule in `lib.sh` (`show_name`), used by the three lints. `board_index_files` lists a card once. Item 4 is a one-line tidy.

**Lead's change to the shaper's draft**: a backslash is escaped too. Without that, a name holding the two characters backslash and `t` reads as a tab.

**Who reads these lines**: `settle-question.sh` takes field 3 of `NO-QUOTE` (a uuid) only. `scripts/release.sh` calls no lint. So the output change breaks no reader in the repo.

**Open calls**: none.
