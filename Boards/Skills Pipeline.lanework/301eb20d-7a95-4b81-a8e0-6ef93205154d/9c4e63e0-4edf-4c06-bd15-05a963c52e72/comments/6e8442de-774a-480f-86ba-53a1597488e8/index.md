---
schema: 1
kind: comment
created:  {at: 2026-11-21T13:18:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; moved to Proposed for review.

Seven of the nine items are kept, six of them reproduced on throwaway boards. Two turned out worse than filed: a card in a symlinked lane, or one with a newline in its name, is skipped silently by all three lints, so a lint can report a clean board it did not read. Dropped: the silent `mktemp` failure (not real, `mktemp` prints its own error and the lint exits 2) and reusing the helper in other scripts (their finds have different contracts). No open call; symlinked lanes are followed, as a symlinked board already is.
