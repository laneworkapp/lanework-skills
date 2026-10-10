# Lanes

Read by `scripts/found-discovery-board.sh` (format: `lanework/templates/pipeline-lanes.md`). `collapsed`: `yes` starts collapsed. `icon`: the lane's `icon` mapping as written, or empty; tint only where it says what the glyph can't (`lanework/references/writes.md` § Icons, colors). `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`lanework/references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | icon | body |
|---|---|---|---|---|
| 1024 | Brief | | | The two standing references: the Topic card (scope) and the Discovery map card (every decision, by corner of the space). The agent rewrites the map at the close of each round, and a resuming session reads it first. |
| 2048 | Facts | | | One card per established fact, with its source; the raw report is an attachment. The agent files each fact as it is established. A fact found wrong gets a dated correction comment, never a hidden edit. |
| 3072 | Asked | | | One card per open question: the question, the options and the recommendation. The owner answers on the card or in chat, and only the agent moves a card out, once the ruling is in the body. |
| 4096 | Settled | | | Answered questions, each ending in a dated ruling in the owner's words. The agent moves a question here once the owner has ruled. A settled question is never edited; a change of mind is a new question that links it. |
| 4608 | Decisions | | | One card per ADR or PDR, titled `ADR:` or `PDR:`, with `Record` and `Status` labels and line 1 linking its question. The agent files it from a question's ruling, before the question settles. Cards never leave; an overturned decision gets the `superseded` status and a dated comment linking its replacement. |
| 5120 | Parked | yes | | Questions the owner deferred or declined, with the reason as the ruling. The agent moves a question here when the owner defers or declines it. Reopen one by asking it again as a new card that links this one. |
