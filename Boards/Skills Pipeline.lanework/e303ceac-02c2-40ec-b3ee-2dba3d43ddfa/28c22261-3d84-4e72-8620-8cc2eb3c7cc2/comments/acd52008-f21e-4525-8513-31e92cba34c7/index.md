---
schema: 1
kind: comment
created:  {at: 2026-11-23T04:03:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T04:03:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: a card one side deleted and the other edited comes back whole.**

- **Fix:** on a whole-card delete, the pass keeps the surviving side's whole tree (every file, its own removals and additions held), reads every stamp the schema allows without raising, and writes before it removes, so an interrupted pass loses no uncommitted edit and a rerun finishes.
- **Not delivered:** the proposal said an added comment or attachment brings a deleted card back. Git merges that case with no conflict, so the pass never sees it. `rules.md` now claims only an edit to an existing file. The rest is card `3ff86cd0` in Issues, with a delete against a bare move.
- **Evidence:** `tests/merge-case.sh` modes `delete`, `stamps`, `interrupt`, each failing on the old script; independent review approved after interruption at eight points across four move scenarios; full smoke on the combined tree: 408 passed.
- **Commits on main:** `11e5cfe0`, `82ed7084`.
- **CHANGELOG:** Merging a board no longer drops files from a card that one side deleted and the other side edited.
