---
schema: 1
kind: card
title: "Lint leftovers: symlinked lanes, odd names, message spelling, smoke gaps"
order: 92160
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}, {text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T01:59:59Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T15:43:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The three board lints (`lint-leases.sh`, `lint-waiting-clears.sh`, `lint-stamps.sh`) stop silently skipping symlinked lanes and cards with a newline in the name, print paths the way the caller spelled them, and the smoke cases that expect silence are made to prove the lint actually read the cards.

## Problem

Leftovers from the review of `6e271bfc` (lints on a symlinked or unreadable board). Each item was checked on a throwaway board under `mktemp -d`.

1. **Symlinked lanes inside a board. Reproduced.** A board whose lane `L1` is a symlink to a folder elsewhere, holding a card with `modified.at: 2099-01-01T00:00:00Z` and an unanswered agent ask: `lint-stamps.sh` prints nothing and exits 0 (the same board with a real lane exits 1 with the finding), `lint-waiting-clears.sh` prints nothing and exits 0 (real lane: `NO-QUOTE c1 k1`, exit 1), `lint-leases.sh` tallies `leased cards: 0`. Cause: `board_index_files` in `skills/lanework/scripts/lib.sh` uses `find -H`, which follows only the folder named on the command line.
2. **Names with a newline. Reproduced.** A card folder named `c2<newline>x`, a copy of a card that has a finding: `lint-stamps.sh` and `lint-waiting-clears.sh` report only the ordinary card, and `lint-leases.sh` with a `START` comment in the newline-named card still says `leased cards: 0`. The card is skipped silently. Cause: `board_index_files` returns one path per line and every caller splits on lines.
3. **awk noise. Reproduced.** With one comment `index.md` at mode 000, `lint-waiting-clears.sh` prints `lint-waiting-clears.sh: could not read <path>` and then `awk: can't open file <path> source line number 15`, exit 2. Cause: the loop `for c in "$card"/comments/*/index.md` only tests `-f`, not readability.
4. **Resolved path in a message. Reproduced.** With a symlink `BL.lanework` to a board holding an unreadable card, `lint-leases.sh BL.lanework` says `could not read /private/var/folders/.../B.lanework/L1/c1/index.md`, while `lint-stamps.sh` and `lint-waiting-clears.sh` say `could not read BL.lanework/L1/c1/index.md`. Cause: `lint-leases.sh` hands the resolved `$r` to `board_index_files`.
5. **Silent `mktemp` failure. Not real.** With `TMPDIR=/nonexistent`, `lint-stamps.sh` and `lint-leases.sh` print `mktemp: mkstemp failed on /nonexistent/lw-find.XXXXXX: No such file or directory` and exit 2. The failure is reported (by `mktemp` itself) and the lint does not go on; `board_index_files` returns 2 at `lib.sh` line 322. Only the script-name prefix is missing, which is not worth a change.
6. **Spelling on a dash-named board. Reproduced.** `lint-stamps.sh -dash.lanework` prints `./-dash.lanework/L1/c1/index.md: modified.at ...`; `lint-waiting-clears.sh -f` (a file) prints `not a board folder: ./-f`. Cause: `board_index_files` prefixes `./` and keeps it in its output; `lint-waiting-clears.sh` prefixes `./` onto `$board` itself.
7. **A smoke line that stops without its message. Reproduced.** `bash -c 'set -euo pipefail; UO=""; PN=$(grep -c . <<<"$UO"); echo reached'` prints nothing and exits 1. In `tests/smoke.sh` (dash case, about line 1168) `PN=$(grep -c . <<<"$UO")` does this when the plain-name run prints nothing, so smoke stops before `unr_fail`.
8. **Smoke cases on boards with nothing to find. Reasoned from `tests/smoke.sh`:** the silent-exit-0 cases are `lint-stamps is silent ... on a clean board` (line 868), the readable-board and restored-mode runs in the mode-000 loop (about 1153 and 1157), and for `lint-waiting-clears.sh` the cases for `waiting` present, a human answer, a record with no handle or in `.trash`, a fractional-second human stamp and the empty board (lines 1063 to 1117). Each would also pass if the lint skipped every card. `lint-leases.sh`'s clean case checks the tally (`leased cards: 2`), so it already proves cards were read. Items 1, 2 and 6 add cases that need the same guard.
9. **Idea: other `find` listings under `skills/*/scripts`. Drop.** `skills/discovery/scripts/file-question.sh` (line 50) and `skills/plan/scripts/file-ticket.sh` (line 72) list lane/card `index.md` files at exactly depth 3 to pick an order or a card to write; `skills/watch/scripts/watch-boards.sh` (line 54) snapshots every `*.md` with `stat`. None wants the lints' read-everything-or-exit-2 contract, none of them is a read-only lint, and swapping them changes behavior for no user-visible gain.

## Change

1. `skills/lanework/scripts/lib.sh`, `board_index_files`: `find -L` instead of `find -H`, so symlinked lanes and cards are followed. A symlink loop shows up in `find`'s stderr and so already becomes a `could not read` line with exit 2. Update the header comment ("symlinked folders are followed").
2. `skills/lanework/scripts/lib.sh`, `board_index_files`: emit NUL-separated paths (`-print0`; the `unreadable_files` filter reads with `read -r -d ''`), and update the three callers: `skills/work/scripts/lint-leases.sh` (the `printf ... | tr '\n' '\0'` pipe goes away; `xargs -0` stays), `lint-waiting-clears.sh` and `lint-stamps.sh` (read with `read -r -d ''`, the per-line `sort` becomes `sort -z`). Findings print the path as found, as today. Name-only edge: a name with a newline prints the newline; that is acceptable, the point is that the card is read. In `lint-leases.sh` Stage 1 `awk` gets paths as arguments, so it is already newline-safe.
3. `skills/work/scripts/lint-waiting-clears.sh`: add `[ -r "$c" ] || continue` beside `-f` in the comment loop (the helper has already printed the could-not-read line and exit 2 follows).
4. `skills/work/scripts/lint-leases.sh`: give `board_index_files` the spelling the caller wrote (`$b`) and pass `LL_BOARD="$b"`; keep `$r` only for the same-board check. The `could not read` line and findings then name the path as given.
5. Dropped (see Problem).
6. `skills/lanework/scripts/lib.sh`, `board_index_files`: when it prefixed `./` for a leading `-`, strip that prefix from every path it prints and from the `could not read` lines, so output uses the caller's spelling. `skills/work/scripts/lint-waiting-clears.sh`: remove its own `board=./$board` line and keep `[ -d "$board" ]` working for a dash name with `-d "./$board"`; the not-a-board message then says `-f`.
7. `tests/smoke.sh`: `PN=$(grep -c . <<<"$UO" || true)`.
8. `tests/smoke.sh`: every silent case gets a sentinel so silence proves the card was read: in the `lint-waiting-clears.sh` block add a helper that writes a listed NO-QUOTE card `c0...9` and expect exactly that card's lines (exit 1); in the `lint-stamps.sh` clean and mode-000 runs make a second card with a future stamp and expect exactly that one finding; in the mode-000 loop the readable and restored runs expect the sentinel too.
9. Dropped.

## Verified

New cases in `tests/smoke.sh`, each failing before the fix:

- Item 1: a copy of a board with a lane replaced by a symlink to the same lane elsewhere; the three lints give the same findings as for the real lane (`lint-stamps.sh` exit 1 with the stamp finding, `lint-waiting-clears.sh` the `NO-QUOTE` line, `lint-leases.sh` `leased cards: 1`).
- Item 2: a card folder and a comment folder whose names contain a newline; each lint finds the finding or `START` inside them (stamps finding, `NO-QUOTE` line, leased-card tally).
- Item 3: with a comment `index.md` at mode 000, `lint-waiting-clears.sh` stderr has exactly the `could not read` line and no `awk:` line, exit 2.
- Item 4: on a symlinked board with an unreadable card, all three lints name the path as given (stderr contains `BL.lanework/`, not the resolved folder).
- Item 6: on `-dash.lanework` the lint-stamps findings begin `-dash.lanework/`, not `./`; `lint-waiting-clears.sh -f` on a file says `not a board folder: -f`.
- Item 7: the dash case run with an empty plain-name output reaches its failure message (case where the plain run is silent: `unr_fail` text prints, smoke does not stop first); checked by a stub script that prints nothing.
- Item 8: each silent case now holds a sentinel; a mutant copy of the lint that skips every card fails it (run once by hand with the helper stubbed to print nothing, not kept in smoke).

## Done when

- `lint-stamps.sh`, `lint-waiting-clears.sh` and `lint-leases.sh` on a board with a symlinked lane report that lane's findings.
- The same on a board with a newline in a card folder name.
- `lint-waiting-clears.sh` on an unreadable comment prints only its own could-not-read line.
- `lint-leases.sh` on a symlinked board names the path as given.
- `lint-stamps.sh -dash.lanework` prints `-dash.lanework/...`.
- `tests/smoke.sh` passes, and with item 7's `|| true` removed from a copy it stops at the named failure message.
- Item 5 and item 9 are recorded as dropped with their reasons on the card.

## Risks

- `find -L` also follows a symlinked card or attachments-free folder that points outside the board, so a lint may read files outside it. The same is already true for a symlinked board; acceptable for read-only lints. A symlink loop becomes exit 2 with a could-not-read line.
- NUL-separated output changes `board_index_files` for any caller that expects lines. The only callers are the three lints; check with `grep -rn board_index_files skills` before the change.
- Bash 3.2 on macOS: `read -r -d ''` works; `sort -z` is supported by the BSD `sort` on macOS 12 and later.
- Printing a path with a newline in it makes a finding span two lines; the sorted order of such lines is not guaranteed.

## Recommendation

Build items 1, 2, 3, 4, 6, 7 and 8; drop items 5 and 9 with the reasons above. Items 1 and 2 are real silent misses (a lint says clean when it did not read a card), the rest are small and share the `board_index_files` change, so they ride in the same commit.
