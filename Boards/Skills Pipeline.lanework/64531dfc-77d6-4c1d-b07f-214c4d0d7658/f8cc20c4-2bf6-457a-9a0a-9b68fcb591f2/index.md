---
schema: 1
kind: card
title: "Lint leftovers 2: tab in a name, unsplittable lines, a lane read twice"
order: 3072
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T16:42:56Z}
---
Reviewer notes from `9c4e63e0` (approved), not fixed there.

## Items

1. **A tab in a card name garbles `lint-stamps.sh` output**: the path is split and the seconds are wrong (`A3.lanework/L1/tab: x/index.md modified.at^I... is 0s ahead`). Predates that card.
2. **Lines cannot be split back apart.** `lint-waiting-clears.sh` prints a card name raw but turns a tab or newline in a comment id into a space, and fields are space-separated. `lint-leases.sh` turns them into spaces everywhere. Decide one escaping rule for the three lints.
3. **A lane symlinked to a sibling lane of the same board is read twice**, so its findings print twice.
4. `lint-waiting-clears.sh:40`: `LW_ID=…` is also set as a global shell variable; harmless, could sit on the `awk` line.

## To shape

Reproduce 1 to 3 on throwaway boards; a smoke case for each one kept.
