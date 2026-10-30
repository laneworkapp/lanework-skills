---
schema: 1
kind: card
title: "Topic: lanework:run, a resident board runner"
order: 1024
icon: {glyph: scope}
created:  {at: 2026-10-30T13:48:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:48:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
`lanework:run` is a proof of concept for running Claude agents against a board continuously, with no session in the loop. A bash loop watches the board. Each change that the board's lane rules care about starts a fresh headless `claude -p` job, scoped to one card. The board holds all memory between jobs, so no context grows however long it runs. The accepted cost: the owner cannot watch an agent's reasoning live, only what it writes on the board and in its logs. The idea came from a brainstorm in the Lanework app session on 2026-10-30. The owner framed the goal the same day: "a proof of concept of a skill that can continuously run claude agents against a board, executing on it according to board's lane rules, while avoiding runaway context growth."

## A shared understanding covers

- Problem: what `dispatch` leaves unsolved, and why a session-less loop is worth trying.
- Scope: which work phase 1 takes on, and what waits for a later phase.
- Behavior: which events start a job, what a job may do, how a parked card resumes, failure and runaway handling.
- Architecture: one runner per board or many, reuse of `watch` and `dispatch` scripts, claims, isolation.
- Constraints: unattended permissions, auth under launchd, machine memory.
- Data: what the runner keeps, where transcripts live, what reaches the board.
- Integrations: Claude Code headless mode, launchd, git, the Lanework app (later phase only).
- Risks: runaway jobs, duplicate work, prompt injection from card bodies, cost.
- Success: what result after how long counts as the proof of concept working.

## Out of scope

- The app launching the runner (NSUserUnixTask): a later phase, explored in the app session. The script's interface stays friendly to it: a board path argument, progress on stdout.
- Seeing the agent's reasoning live: accepted cost of `claude -p`, owner ruling 2026-10-30.
- New board format or schema keys in the app's guide: only if the proof of concept shows they earn it.

## Sources read

- `skills/dispatch/`: event classes, routing table, state, handler rules.
- `skills/watch/`: the watcher script and event rules.
- `skills/work/`: agent lanes, build cycle, asks and `waiting`.
- `lanework/references/board-kinds.md` § Pipeline: the lane actors table.
- Board guide v102 (Skills Pipeline) and v84 (this board).
- Claude Code docs on headless mode, permissions, sessions, worktrees, env vars, scheduling.
