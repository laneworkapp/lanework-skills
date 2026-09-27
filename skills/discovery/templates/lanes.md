# Lanes

Read by `scripts/found-discovery-board.sh`, one row per lane. `collapsed`: `yes` starts the lane collapsed. `body`: the lane's `index.md` body, owner-facing, no `|`.

| order | title | collapsed | body |
|---|---|---|---|
| 1024 | Brief | | The two standing references. The Topic card states the scope and what a shared understanding must cover. The Discovery map card is the outline of every decision, grouped by corner of the space, rewritten by the agent at the close of each round, and is the first thing a resuming session reads. |
| 2048 | Facts | | One card per fact the agent established: from the code, the docs, the filesystem, a tool, or the web. The body is the fact and its source; the raw report is an attachment. A fact found wrong gets a dated correction comment, never an edit that hides the first reading. |
| 3072 | Asked | | One card per open question, filed by the agent, waiting on the owner. The body is the question, the options and the recommendation. Answer by commenting on the card or by replying in chat. Only the agent moves a card out, and only once the ruling is written into the body. |
| 4096 | Settled | | Answered questions. The body ends with a dated ruling in the owner's words. This lane is the design record: read it in order to see what was decided and why. A settled question is never edited; a change of mind is a new question in a later round that links this one. |
| 5120 | Parked | yes | Questions the owner deferred or declined, with the reason as the ruling. Collapsed because it is read least; reopen one by asking it again as a new card that links this one. |
