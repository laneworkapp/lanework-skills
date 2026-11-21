---
schema: 1
kind: comment
created:  {at: 2026-11-21T01:59:56Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `8701b34` and pushed. Not released.

**What changed:**

- `skills/lanework/scripts/lib.sh` gains two helpers: `board_index_files` (follows a symlinked board, and prefixes `./` to a relative board path starting with a dash) and `unreadable_files`.
- `lint-leases.sh`, `lint-waiting-clears.sh` and `lint-stamps.sh` use them. When part of the board can't be read, each prints `<script>: could not read <path>` to stderr and exits 2, where it used to report a clean board. `lint-stamps.sh` now follows a symlinked board.
- A path that vanishes between the listing and the read is skipped silently; only a path that exists and can't be read is an error.
- `skills/discovery/scripts/settle-question.sh` treats a lint exit of 2 or more as a failure: it stops with `lint-waiting-clears.sh failed (exit N)` and writes nothing.

**Departure from the proposal:** the card said "Findings from what was read still print first". The could-not-read lines go to stderr before the findings; what was read still prints. The three headers state the real order.

**Evidence:**

- `tests/smoke.sh` on `main` at `8701b34`: `smoke: 313 passed`, exit 0.
- New smoke cases: symlinked board, mode-000 card and comment, a lint exiting 2 under settle-question, a board named with a leading dash (run on boards with findings and compared with the same board under a plain name), a vanished path.
- The reviewer removed each rule in turn and confirmed its case fails.
- Review: three rounds, approved at `0b850df`. Round 2 introduced a real bug: `lint-waiting-clears.sh` listed nothing and exited 0 on a dash-named board. The reviewer caught it; smoke had missed it because the case ran on a board with nothing to find.

**Left open**, filed as a follow-up card in Issues: symlinked lanes inside a board in `lint-waiting-clears.sh`; names with a newline; awk noise on an unreadable comment; the resolved path in the `lint-leases.sh` message; a silent `mktemp` failure; `./` spelling in messages on a dash-named board; a smoke line that stops without its message.

**CHANGELOG sentence:** The Lanework lints now stop with an error, instead of reporting a clean board, when part of the board can't be read, and `lint-stamps` now follows a symlinked board.
