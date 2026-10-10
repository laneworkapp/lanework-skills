# Board

## Find or found

- Name `<Topic> Plan.lanework`, where the project's boards live (`lanework/references/finding.md`).
- Look first: board the user names, or the idea's existing board → Work it. Never duplicate.
- None fits → `scripts/found-plan-board.sh`, then open once in the app (installs guide + schema) before filing.

## Lanes

Map · Frontier · Blocked · Working · Resolved · Decisions · Out of scope. Order, collapse, each lane's policy: `templates/lanes.md`. Who acts: `lanework/references/board-kinds.md` § Plan.

## Cards

| card | lane | template |
|---|---|---|
| Map | Map, order 1024 | `templates/map-card.md` |
| Ticket | Frontier / Blocked → Working → Resolved / Out of scope | `templates/ticket-card.md` |
| Record (ADR/PDR) | Decisions, filed there directly | `discovery/templates/record.md` |

Resolution: `templates/resolution.md`. Templates: `{{key}}` script-filled (fill yourself when writing by hand), `<hint>` hand-filled, stamps per `lanework/references/writes.md`.

## Moves

Only the agent, only by script. Owner never moves cards: a comment or chat reply is the whole gesture.

| move | when | script |
|---|---|---|
| new → Frontier / Blocked | filed; Blocked while a dependency isn't Resolved | `scripts/file-ticket.sh` |
| Frontier → Working | claimed, before any work | `scripts/claim-ticket.sh` |
| Working → Resolved | Resolution written | `scripts/resolve-ticket.sh` |
| Blocked → Frontier | its last dependency resolves | same run, automatically |
| Frontier / Blocked / Working → Out of scope | ruled past the destination | `resolve-ticket.sh --to out-of-scope` |

- Records go straight into Decisions: `discovery/scripts/file-record.sh --from Working`.
- Map, Resolved, Decisions, Out of scope cards never leave. Change of mind → new ticket linking the old.
- Lane drift (hand edit, crash mid-script) → `scripts/frontier.sh` names it; fix by the move rules above.

## Order

- Placing: `lanework/references/writes.md` § Placing. A moved card lands at the bottom: Resolved reads as the route walked.
- Frontier top = next ticket. Reprioritising = rewrite `order` within the lane (`writes.md` § Moving).
- T numbers: global, in filing order. Minted from the highest `T<n>` across all lanes (`file-ticket.sh` does).
