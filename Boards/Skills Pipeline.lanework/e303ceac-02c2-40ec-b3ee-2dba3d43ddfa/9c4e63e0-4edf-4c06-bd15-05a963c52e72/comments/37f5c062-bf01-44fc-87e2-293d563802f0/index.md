---
schema: 1
kind: comment
created:  {at: 2026-11-21T15:43:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to main at `144e10c` (branch `lint-leftovers`, head `106f92c`).

**Changed**: the three lints follow symlinked lanes and cards, handle a newline in a card or comment folder name, report an unreadable comment as one `could not read` line with exit 2, and print paths as typed (symlinked board, a board named `-dash.lanework`). Cases that expect silence now run on a board with a sentinel finding.

**Departures**: `board_index_files <dir> <outfile>` writes NUL-separated paths to a file, since a shell variable cannot hold NULs. Values reach awk through `ENVIRON`.

**Review**: round 1 requested changes (a case that could not fail; a trailing-newline card name skipped silently by `lint-waiting-clears.sh`). Round 2 approved; both mutations fail a case.

**Evidence**: `tests/smoke.sh` on main at `da2bf8a`: `smoke: 331 passed`, rc 0.

**Dropped from the card**: items 5 and 9, for the reasons in the card body.

**Left open** (filed as one Issues card): a tab in a card name garbles `lint-stamps.sh` output; space-separated output cannot be split when a name holds a space; a lane symlinked to a sibling lane is read twice.

**CHANGELOG**: Board lints no longer skip symlinked lanes or cards with a newline in the name, and they report paths the way you typed them.
