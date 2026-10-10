---
name: plan
description: "Multi-session planning on a Lanework plan board: name the destination, chart its open decisions as ticket cards, resolve one per session until nothing is left to decide. Run as /lanework:plan <idea> to chart, /lanework:plan <board> [T<n>] to work a ticket."
disable-model-invocation: true
---

# Plan

Idea too big for one session → destination → open decisions as tickets → one per session → done when nothing is left to decide. Board = the record, chat = the conversation.

**Plan, don't do**: decisions, not deliverables. The map's Notes may override.

- **Destination**: the spec, decision or change the plan heads for. Fixes scope; settled first.
- **Ticket** `T<n>`: one question resolving to a decision, sized to one session.
- **Frontier**: specified, dependencies resolved, unclaimed. Top = next.
- **Fog**: in-scope decisions not yet sharp enough to ticket.
- **Map**: one card, the index. Rewritten after every resolution.

## Authority

Builds on **lanework**: read `lanework/references/authority.md` before any write. Board files beat this skill.

## Topics

| topic | file |
|---|---|
| board: find/found, lanes, cards, moves | `references/board.md` |
| map card, fog vs ticket, out of scope | `references/map.md` |
| tickets: types, depends, claim, resolve | `references/tickets.md` |
| sessions: chart, work, finish | `references/sessions.md` |
| asking the owner, answers | `discovery/references/rounds.md` § Ask, § Answers; `discovery/references/conduct.md` |
| glossary, ADR and PDR cards | `discovery/references/records.md` |
| literal file shapes | `templates/` |

## Flow

1. `/lanework:plan <idea>` → **Chart** (`references/sessions.md` § Chart).
2. `/lanework:plan <board> [T<n>]` → **Work** the named ticket, else the top of Frontier (§ Work).
3. **One ticket per session.** Research excepted: subagents, in parallel.
4. Frontier, Blocked, Working empty, no fog → **Finish** (§ Finish). **Build nothing and file no work cards until the owner says so.**

## Resume

From the board, never memory: Work step 1. Owner wants to answer on the board while you wait → suggest `/watch <board>` (the owner types it; Claude can't start a watch).

## Scripts

`scripts/`, built on `lanework/scripts/`. Full usage in each header.

| script | does |
|---|---|
| `found-plan-board.sh <path> [title] --model m` | founds the board from `templates/board.md` + `templates/lanes.md` |
| `file-ticket.sh <board> <title> --type t --body F [--depends <link>]... --model m` | next T into Frontier, or Blocked while a dependency is open |
| `claim-ticket.sh <board> <card-uuid> --model m` | Frontier → Working + Claimed comment; refuses any other lane |
| `resolve-ticket.sh <board> <card-uuid> --resolution F --model m` | appends it, → Resolved (or `--to out-of-scope`), unblocks dependents |
| `frontier.sh <board>` | live tickets, open dependencies; warns on drift |
| `discovery/scripts/file-record.sh … --from Working` | ADR/PDR card into Decisions, before the ticket resolves |
