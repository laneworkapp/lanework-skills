---
schema: 1
kind: card
title: "plan: chart and resolve the decisions between an idea and a clear way, on a plan board"
order: 1024
labels: [{text: plan, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T18:22:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "plan skill"}}
modified: {at: 2026-10-10T18:22:14Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "plan skill"}}
---
A new human-invoked skill, `plan`. It takes an idea too big for one session, names its destination, and charts the decisions on the way as ticket cards on a plan board. Each session then resolves one ticket, until nothing is left to decide. Adapted from Matt Pocock's `wayfinder`, narrowed to planning, built on discovery's asking and records rules.

## Decided (owner, 2026-10-10, in chat)

- **Name `plan`**: invoked as `/lanework:plan`. A by-hand install symlinks it as `~/.claude/skills/lanework-plan`, because a bare `plan` replaces the built-in `/plan` in a local terminal.
- **Board, 7 lanes**: Map · Frontier · Blocked · Working · Resolved · Decisions · Out of scope (collapsed). Claiming a ticket = moving it to Working. Resolving a ticket moves every Blocked ticket it was the last open dependency of to Frontier.
- **Labels**: `Ticket` = Grilling | Research | Prototype | Task. `Record` + `Status` as in discovery. Tickets are numbered T<n> across the board.

## Touches

`skills/plan/` (new: SKILL.md, references, templates, scripts), `skills/discovery/scripts/file-record.sh` (`--from <lane>`), `skills/lanework/references/board-kinds.md` (Plan lane actors), `skills/lanework/SKILL.md`, `.claude-plugin/plugin.json`, `README.md` (skills table, invocation, sizes, install, names, credits), `tests/smoke.sh`.

## Verify

`tests/smoke.sh` passes, with new cases for every plan script on scratch boards outside the repo.

## Done when

`/lanework:plan <idea>` can found a plan board and file tickets, `/lanework:plan <board>` can claim, resolve and unblock tickets, every new script has smoke coverage, and plugin.json and the README list the skill.
