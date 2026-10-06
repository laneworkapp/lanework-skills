---
name: discovery
description: "Question-by-question examination of a project's problem and domain space on a Lanework discovery board, producing a glossary, ADRs and PDRs. Run as /discovery <topic>."
disable-model-invocation: true
---

# Discovery

Agent asks, owner rules, until every corner of the problem/domain space is settled or ruled out. Board = the record, chat = the conversation. Output: board, glossary, ADRs, PDRs.

- **Discovery map**: tree of every decision, grouped by corner. One card, rewritten each round.
- **Frontier**: decisions whose prerequisites are settled. A round asks the whole frontier.

## Authority

Builds on **lanework**: read `lanework/references/authority.md` before any write. Board files beat this skill.

## Topics

| topic | file |
|---|---|
| corners of the space | `references/corners.md` |
| board: find/found, lanes, cards, moves, order | `references/board.md` |
| rounds: frontier, ask, answers, close | `references/rounds.md` |
| glossary, ADRs, PDRs | `references/records.md` |
| writing rules | `references/conduct.md` |
| literal file shapes | `templates/` |

## Flow

1. **Board**: find or found → `references/board.md`.
2. **Frame**: read code, docs, `docs/adr/`, `docs/pdr/`, `CONTEXT.md`, prior cards on the topic. Facts are the agent's job, never the owner's: subagent → Facts card. Write the Topic card and the first map (every visible decision, per `references/corners.md`).
3. **Ask** the frontier → `references/rounds.md`.
4. **Take answers** → `references/rounds.md`.
5. **Close the round** → `references/rounds.md`, then back to 3.
6. **Finish** when the frontier is empty and every corner is settled or out of scope. Closing record on the Topic card: settled/parked counts, records and glossary terms linked, one paragraph on what was agreed. Then one ask: is this a shared understanding? **Build nothing and file no work cards until the owner says so.** Work cards then go on the project's pipeline board, linking back.

## Resume

From the board, never memory:

1. `lanework/scripts/read-board.sh`, then the map card.
2. Each Asked thread: owner comment newer than `waiting.since` = unrecorded answer → record it first.
3. Continue at Flow 5.

Owner wants to answer on the board while you wait → suggest `/pitwall <board>` (the owner types it; Claude can't start a watch).

## Scripts

`scripts/`, built on `lanework/scripts/`. Full usage in each header.

| script | does |
|---|---|
| `found-discovery-board.sh <path> [title]` | founds the board: `found-board.sh` with `templates/board.md` + `templates/lanes.md` |
| `file-question.sh <board> <title> --round N --body F` | files the next Q into Asked, with founding + ask comments |
| `settle-question.sh <board> <card-uuid> --ruling F` | appends the ruling, clears `waiting`, moves to Settled (or `--to parked`) |
