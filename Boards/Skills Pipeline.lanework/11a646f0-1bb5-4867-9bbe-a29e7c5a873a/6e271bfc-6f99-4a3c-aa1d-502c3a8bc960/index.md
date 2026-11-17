---
schema: 1
kind: card
title: "Lints: a symlinked board or an unreadable folder reads as clean"
order: 7168
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T23:21:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T23:21:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Two cases where a lint in `skills/work/scripts` exits 0 and prints nothing without having read the board. Both are on main and not released. Found in the review of [the lease lint](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b).

## `lint-stamps.sh` does not follow a symlinked board

- A board passed as a symlink is not descended into: BSD `find` stops at the link.
- Measured in that review: exit 0 on a symlinked board whose real path exits 1.
- `lint-leases.sh` had the same fault and now resolves each board with `cd … && pwd -P` before reading. The same change fits here.

## `lint-leases.sh` reads an unreadable folder as empty

- A board folder or a lane that `find` cannot list gives exit 0 and `leased cards: 0`. Only `find: … Permission denied` on stderr shows it.
- Measured on a board with mode 311 and a lane with mode 000.
- Fix direction: check the status of `find` and exit 2.
- `lint-stamps.sh` is unchecked for this.

## Reach

Neither touches the lease trial: this repo's boards are real, readable folders. A lint that reads clean without reading is the risk for anyone else's boards.
