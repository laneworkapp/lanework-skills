---
schema: 1
kind: card
title: "Lints: a symlinked board or an unreadable folder reads as clean"
order: 6144
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T23:21:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T13:42:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Three lints under `skills/work/scripts` can exit 0 on a board they did not fully read: `lint-stamps.sh` on a symlinked board, and `lint-stamps.sh`, `lint-leases.sh` and `lint-waiting-clears.sh` on an unreadable folder or file. The fix is to follow a symlinked board and to exit 2 whenever any part of the board could not be read.

## Today

All measured on a throwaway board (one lane with a card carrying a future stamp and a START comment, a second empty lane) and a symlink to it.

1. **Symlinked board.**
   - `lint-stamps.sh <link>` exits 0 and prints nothing; the real path exits 1 with three findings. `lint-stamps.sh <link>/` (trailing slash) finds them. The cause is `files()` at `skills/work/scripts/lint-stamps.sh:26`: `find "$target"` does not descend a command-line symlink.
   - `lint-leases.sh <link>` is already fixed on main (`lint-leases.sh:49` resolves with `pwd -P`; smoke covers it at `tests/smoke.sh:877`). `lint-waiting-clears.sh <link>` reads through the link, because its glob at `:43` follows symlinks. `lint-ask.sh` takes a file, not a board.

2. **Unreadable folder or file.** With a lane at mode 000, a card folder at mode 000, or a board root at mode 000:
   - `lint-leases.sh` prints `find: … Permission denied` and `leased cards: 0, …`, exit 0 (`:162` pipeline, status lost).
   - `lint-stamps.sh` prints the `find` error, exit 0 (`:35` and `:65`; the `find` status is lost in `files | while` and the process substitution).
   - `lint-waiting-clears.sh` prints nothing at all and exits 0: the glob at `:43` just matches nothing.
   - With a card `index.md` at mode 000, `awk` prints `can't open file` in all three and the exit code ignores it (`lint-stamps.sh` and `lint-waiting-clears.sh` give 0 when nothing else is found; `lint-leases.sh` gives 0 with `leased cards: 0`).

The old body said `lint-stamps.sh` was unchecked for the unreadable case. It is affected, and so is `lint-waiting-clears.sh`.

## Change

1. **Follow a symlinked board** (could be dropped; the unreadable fix does not depend on it).
   - `skills/work/scripts/lint-stamps.sh`: `find -H "$target" …` at `:26`. `-H` follows only the command-line argument, works on BSD and GNU `find`, and keeps the spelling the caller gave in the output. Measured: `find -H <link> -mindepth 1 -name index.md` lists the board.
   - `lint-waiting-clears.sh` needs no change.

2. **Exit 2 when anything could not be read.** Rule: a lint that did not read the whole board never exits 0 or 1 alone; it exits 2 with `<script>: could not read <path>` on stderr. Findings from what was read still print first.
   - `skills/lanework/scripts/lib.sh`: add `board_index_files <dir>`, which runs `find -H` once into a temp list, returns 2 if `find` exits non-zero, and prints the list. Add `unreadable_files` that reports any listed `index.md` that fails `[ -r ]`. One home for the rule.
   - `skills/work/scripts/lint-stamps.sh` and `lint-leases.sh`: build the file list through the helper instead of an inline `find` (leases keeps its stage 1 and 2 awk; only the `find` line at `:162` changes). On a helper failure, finish, then exit 2. Update the header comments (`exit 2 … or an unreadable path`).
   - `skills/work/scripts/lint-waiting-clears.sh`: replace the glob at `:43` and `:47` with the same helper, so an unreadable lane or card is seen. Keep the output format.
   - `tests/smoke.sh`: cases listed under Done when.
   - `skills/work/references/` is not touched; no doc names these exit codes beyond the script headers (read; confirm with `tests/check-refs.sh`).

## Not in scope

- `lint-ask.sh`: it reads one file, so neither fault applies.
- Other scripts under `skills/*/scripts` that use `find`; only the `lint-*.sh` family is covered here.
- Making the lints read as the owner of the files or retry; an unreadable folder is reported, not repaired.
- A `chmod` fix-up hint in the message.

## Risks

- Smoke cases that `chmod 000` do nothing when run as root, since root reads everything. Guard each case with a check that the folder really is unreadable (`[ ! -r ]`), and skip with a printed note otherwise. The CI workflow runs as a normal user.
- Changing `lint-waiting-clears.sh` from a glob to `find` changes the card order if it was relying on glob sorting. Pipe the list through `sort`.
- Exit 2 on an unreadable file turns a previously green run red on boards with a stray mode-000 file. That is the intent.

## Done when

- `tests/smoke.sh` passes, with new cases:
  - `lint-stamps.sh <symlink to a board with a future stamp>` exits 1 and names the same files as the real path.
  - For each of `lint-stamps.sh`, `lint-leases.sh`, `lint-waiting-clears.sh`: a lane at mode 000, a card folder at mode 000 and a card `index.md` at mode 000 each give exit 2 and a `could not read` line on stderr, with the mode restored afterwards.
  - The same three on a readable board still exit 0 and stay silent (leases still prints its tally on stderr).
- `tests/check-refs.sh` and `tests/check-sizes.sh` pass.
- By hand: `chmod 000 <board>/<lane>; skills/work/scripts/lint-leases.sh <board>; echo $?` prints `2`.

Bump: patch.
