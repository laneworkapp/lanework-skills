# Sessions

Two modes. Never more than one ticket resolved per session, Research excepted. Expect concurrent sessions: re-read before every write.

## Chart

`/lanework:plan <idea>`. One session; resolves no HITL ticket.

1. **Board**: find (`board.md`). The idea has a board → Work instead. None → found it at step 4, once there's fog.
2. **Destination**: grill in chat (ask shape: `discovery/references/rounds.md` § Ask, a recommendation each) until the spec, decision or change is named. Settled first: it fixes scope.
3. **Frontier**: breadth-first across `discovery/references/corners.md`: the open decisions, the first steps takeable now. No fog (way already clear, fits one session) → no board needed: stop, ask the owner how to proceed.
4. **Map card**, on the board founded now: Destination, Notes, empty Decisions so far, fog sketched (`map.md`). The owner's words naming the destination → its first thread comment.
5. **Tickets**: file every one specifiable now, dependencies first (`tickets.md` § Depends on). The rest stays fog.
6. **Research**: claim each Research ticket and dispatch it to a subagent, all in parallel (`work/references/tiers.md`). Each resolves its own ticket.
7. **Stop.** Chat: destination, frontier, fog, each ticket linked by name.

## Work

`/lanework:plan <board> [T<n>]`.

1. **Read**: `lanework/scripts/read-board.sh`, then the Map card only. Not every ticket body. `scripts/frontier.sh` for the live tickets.
2. **Pick**: the named ticket, else the top of Frontier. `scripts/claim-ticket.sh` first. Owner names a Working ticket (HITL left waiting) → resume it, no claim; an owner comment newer than `waiting.since` = its answer.
3. **Resolve** per type (`tickets.md` § Types). Zoom into related or Resolved tickets on demand. Use the skills the Notes name.
4. **Records**: ADR/PDR before resolving, pinned terms into `CONTEXT.md` (`discovery/references/records.md`). Then `scripts/resolve-ticket.sh`.
5. **Map**: rewrite (`map.md`): Decisions so far line; fog now specifiable → new tickets, patch cleared; newly surfaced tickets; out-of-scope rulings; tickets the decision invalidated → Moot.
6. **Stop.** One ticket per session. Chat: the resolution, what unblocked, the next ticket by name.

## Finish

Frontier, Blocked, Working empty and no fog:

1. Closing record on the Map card: resolved / moot / out-of-scope counts, record cards and glossary terms linked, one paragraph on the way found.
2. One ask: is the way clear?
3. **Build nothing and file no work cards until the owner says so.** Work cards then go on the project's pipeline board, linking back.
