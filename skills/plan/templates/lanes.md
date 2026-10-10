# Lanes

Read by `scripts/found-plan-board.sh` (format: `lanework/templates/pipeline-lanes.md`). `collapsed`: `yes` starts collapsed. `icon`: the lane's `icon` mapping as written, or empty; tint only where it says what the glyph can't (`lanework/references/writes.md` § Icons, colors). `body`: owner-facing lane policy, no `|`. A body's 2nd sentence = who acts + what starts it (`lanework/references/board-kinds.md`); `heal` reads it.

| order | title | collapsed | icon | body |
|---|---|---|---|---|
| 1024 | Map | | {glyph: map} | The Map card: the destination, standing notes, the decisions so far, what is not yet specified and what is out of scope. The agent rewrites it each time a ticket resolves, and a resuming session reads it first. |
| 2048 | Frontier | | {glyph: flag} | Tickets ready to take, top first: specified, every dependency resolved, unclaimed. Agents claim one only when a plan session is started on this board, taking the top ticket unless the owner names another. |
| 3072 | Blocked | | {glyph: lock} | Specified tickets with a dependency not yet resolved, listed under Depends on. No one acts on them here: when the last dependency resolves, the resolving script moves the ticket to Frontier. |
| 4096 | Working | | {glyph: hourglass} | Tickets claimed by a session, one per session. The agent that claimed a ticket resolves it; a ticket that needs the owner waits here, marked waiting, until the owner answers on the card or in chat. |
| 5120 | Resolved | | {glyph: checkmark.circle} | Tickets with their resolution appended, in the order resolved: the route walked. The agent moves a ticket in once its resolution is written. A resolved ticket is never edited; a change of mind is a new ticket that links it. |
| 5632 | Decisions | | {glyph: signpost.right} | One card per ADR or PDR, titled `ADR:` or `PDR:`, with `Record` and `Status` labels and line 1 linking its ticket. The agent files it from a ticket's resolution, before the ticket resolves. Cards never leave; an overturned decision gets the `superseded` status and a dated comment linking its replacement. |
| 6144 | Out of scope | yes | {glyph: xmark.circle} | Tickets ruled past the destination, each with one line why. The agent moves a ticket here when it is ruled out of scope. It comes back only as a new plan with a redrawn destination. |
