---
schema: 1
kind: comment
created:  {at: 2026-11-21T13:18:42Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; moved to Proposed for review.

Six of the seven items are kept and five were reproduced on throwaway repos. The two that matter: a `--push` retry after an interrupted run says "nothing to commit" and exits 0 with the commit never pushed, and a push that never returns holds the script with no bound. The hang is reasoned from the code, not run. Dropped: SIGINT to the script alone, which the header already documents. No open call; the push bound defaults to 120 seconds with `LANEWORK_PUSH_TIMEOUT` to change it.
