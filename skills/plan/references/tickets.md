# Tickets

Ticket = one question whose resolution is a decision, sized to one session. Card: `templates/ticket-card.md`, filed by `scripts/file-ticket.sh`. Body = the question, one paragraph above the first `##`. The answer goes only in `## Resolution`.

## Types

`Ticket` label. **HITL** = resolves only through the owner, speaking for themselves. **AFK** = agent alone.

| type | mode | when | resolves by |
|---|---|---|---|
| Grilling | HITL, default | a call only the owner can make | ask on the ticket card (`discovery/references/rounds.md` § Ask, § Answers); resolution = owner's words |
| Research | AFK | a fact outside the repo the decision waits on | subagent (tier: `work/references/tiers.md`), findings attached as a file; resolution = cited fact |
| Prototype | HITL | "how should it look or behave" is the question | cheap rough artifact (outline, stub, mock) attached; owner reacts; resolution = owner's words |
| Task | AFK or HITL | manual work blocks a decision: sign up, provision, move data | agent does it, or a checklist ask; resolution = what was done + resulting facts |

- HITL never resolves without the owner's own words. The agent never answers its own asks.
- Task is the one type that does. It earns its place by unblocking a decision, never by delivering the destination.
- Ask conduct (recommendation always, `waiting`, chat answers, challenge): `discovery/references/conduct.md`, `discovery/references/rounds.md` § Answers. Chat posts link the ticket by name (`map.md` § Refer by name).

## Depends on

- `## Depends on` = tickets that must resolve first. `file-ticket.sh --depends <link>` writes it and files into Blocked until all are Resolved.
- File dependencies first: a `--depends` target must exist. Topological order: no cycles, no second pass.
- Dependency in Out of scope → refused: rule the dependent out too, or drop the dependency.

## Claim

- `scripts/claim-ticket.sh`: Frontier → Working + a Claimed comment, **before any work**. Refuses a card not in Frontier.
- Concurrent sessions skip Working tickets. A HITL ticket waits there wearing `waiting`.

## Resolve

1. Resolution clears the bar (`discovery/references/records.md` § Bar) → file the ADR/PDR first: `discovery/scripts/file-record.sh <board> <ticket-uuid> --from Working …`. Its link goes in the Resolution.
2. Write the Resolution: `templates/resolution.md`.
3. `scripts/resolve-ticket.sh` → Resolved. Blocked tickets whose dependencies are all Resolved move to Frontier.

- **Moot**: invalidated by another decision → resolve as `Moot: <why>`, linking the deciding ticket. Claim it first.
- Missed record (ticket already Resolved) → a new ticket linking the old one files it.

## Out of scope

Mis-scoped ticket → `resolve-ticket.sh --to out-of-scope` (from Frontier, Blocked or Working), Resolution = why. One line in the map's Out of scope.

## Editing

- Unclaimed Frontier / Blocked body: may be rewritten while sharpening (restamp `modified`). Depends on changed → `scripts/frontier.sh`, fix the drift it names.
- Working: the claiming session only. Resolved: never edited.
