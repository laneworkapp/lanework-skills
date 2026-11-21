---
schema: 1
kind: card
title: "Lint leftovers: symlinked lanes, odd names, message spelling, smoke gaps"
order: 6144
created:  {at: 2026-11-21T01:59:59Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T01:59:59Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
## Problem

Leftovers from the review of `6e271bfc` (lints on a symlinked or unreadable board, merged at `8701b34`). None blocks 0.9.0.

1. **Symlinked lanes inside a board.** `lint-waiting-clears.sh` follows a symlinked board, not a symlinked lane inside one.
2. **Names with a newline.** A card or comment folder name containing a newline breaks the line-based file listing in the three lints.
3. **awk noise.** On an unreadable comment, `lint-waiting-clears.sh` prints an awk error next to its own could-not-read line.
4. **Resolved path in a message.** `lint-leases.sh` names the resolved path in its could-not-read line, not the path the caller gave.
5. **Silent `mktemp` failure.** A lint whose `mktemp` fails goes on without saying so.
6. **Spelling on a dash-named board.** `lint-stamps.sh` prints findings as `./-dash.lanework/...`, and `lint-waiting-clears.sh` says `not a board folder: ./-file`, where the caller wrote the name without `./`.
7. **A smoke line that stops without its message.** In the dash case of `tests/smoke.sh`, `PN=$(grep -c . <<<"$UO")` exits 1 under `set -e` when the plain-name run prints nothing, so smoke stops without the failure message. `|| true` keeps the message.
8. **Smoke cases on boards with nothing to find.** A case that expects silent exit 0 also passes when the lint skips every card. Check the remaining lint cases run on boards that have findings.
9. **Idea:** other scripts under `skills/*/scripts` that list a board with `find` could use `board_index_files`.

## Done when

Items 1 to 8 each fixed with a smoke case that fails without the fix, or ruled out with a reason. Item 9 decided: do or drop.
