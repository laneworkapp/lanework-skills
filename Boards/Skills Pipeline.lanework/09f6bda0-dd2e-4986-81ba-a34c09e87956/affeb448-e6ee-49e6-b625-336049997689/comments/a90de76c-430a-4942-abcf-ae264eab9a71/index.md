---
schema: 1
kind: comment
created:  {at: 2026-11-28T04:55:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T04:55:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Built: `heal-board.py` now makes the same call as the board's heal v6 on every case the card lists, and a board copy older than it no longer blocks it.**

- **Commits** on branch `healer-v6`: `4b19f368` the port, `writes.md` and the README word counts; `7664662f` smoke, `scripts/release.sh` and the repo `CLAUDE.md`; `761c472d` one smoke fixture moved to damage heal v6 still repairs.
- **How the cases compare**: each new case seeds one throwaway board, heals a copy with `heal-board.py` and a copy with the board's healer, and requires the same dry-run lines, the same files (stamp spacing aside) and the same record bodies (the script's name in the "Run by" line aside). Each also checks `heal-board.py`'s own result directly, so it still tests the port when the comparison is skipped.
- **H03 bare-icon**: an `iconColor` the mapping overrides, or one with no colour reading, is now quoted in a record on a card and left as written on a board or lane. Case: the icons board (ok "heal: iconColor on the board and a lane is left").
- **H05 definition**: a bare `glyph:` beside a different `icon` in `config.labels` is left as written, as a skip. Same case.
- **H01 title-quote**: only a title YAML cannot read as one line is rewritten. `title: ~` is a skip, and single-quoted, readable plain and two-line quoted titles stay byte for byte. Same case, plus the damage board's existing checks, moved to the new behaviour.
- **H07 to H11, H13 records**: a rewrite that replaces what the card wrote posts a record quoting its `labels` line first. Cases: icons (rank 7, a shadowed glyph on a label) and roster (a root `priority:` with a subkey no label carries).
- **Unknown subkeys**: they now survive on the entry, its `kind` and its `icon`. Icons case: `note: "k"` and `tint: "x"` survive.
- **H11 root-key**: the four keys are kept and the rest is quoted in a record. Roster case.
- **H15 config-priorities**: the roster becomes the `priority` definition and is read as it while cards heal, so a card keeps rank 1 and colour red. One that cannot be carried whole is a skip. Roster and odd-roster cases.
- **H16 config-collapse-empty**: removed when empty, a skip when it has a value. Same two cases.
- **H06 added-definition**: no addition where `config.labels` or the roster already defines the kind. Roster case (no H06 line); the existing label-kinds case still adds one where it is missing.
- **Definitions read**: a value with an unreadable `rank` drops out, so its entries stay foreign. Roster case (`S` keeps rank 9).
- **Idempotent record**: an apply whose records landed but whose files did not, run again, finishes the files and posts no second record. Rerun case, run on both healers.
- **Output**: every line is `<file>: Hnn <code> <what>`. Case "every heal repair line carries its rule id", plus the H17, H11 and H02 greps moved to that form.
- **Extra parity check**: the existing damage board is also healed side by side and matches.
- **Which copy**: the version comes from line 2 of the board's `.schema/bin/lanework-heal.py`. At `HEAL_VERSION` (6) or later: exit 2, naming it. Older, or no version stated: the skills' copy heals and says so in one stderr line. `--ignore-board-copy` skips the check. Case: stub board healers at v5, without a version, at v6 and at v7. `--name anyone` still exits 64 with nothing written (its own case).
- **Drift**: smoke prints a note when the board's healer states a later version than `HEAL_VERSION`. `release.sh` warns for the working tree and for HEAD, with a scratch-repo case at v7 and at v6. Smoke also fails if `HEAL_VERSION` and the `lanework-heal v6` stamp in `CLAUDE.md` disagree.
- **Evidence, gates**: `bash -n` passes on `tests/smoke.sh` and `scripts/release.sh`. `py_compile` passes with the cache outside the tree, and no `__pycache__` is left. `heal-board.py` runs under `/usr/bin/python3` (3.9.6). `check-refs: 262 references, 0 missing`. `check-sizes: 59 rows, 0 wrong`.
- **Evidence, smoke with `SMOKE_BOARD_HEALER` set to the v6 file on disk**: `smoke: 171 passed (sections: static, founding, heal_board, plan, lint_ask, merge, label_kinds, versions, compact_form, filing_defaults, board_writes, headers, release_gate, cite_as, heal_descriptors, usage_guard, plugin, signature, import)`. The side-by-side cases ran: 5 rows name the board heal v6.
- **Evidence, smoke without it**: the worktree's committed board healer is v5. The run printed `note: the board's healer is at heal v5, older than heal-board.py's v6: the side-by-side heal cases are skipped`, then `smoke: 18 passed (sections: heal_board, release_gate)`. Runs pointed at a v7 stub and at a missing file printed the drift note and the missing note, and both ended `smoke: 16 passed (sections: heal_board)`.
- **Evidence, fail-before**: the new cases were run against `main`'s `heal-board.py`. Each side-by-side case (icons, roster, odd-roster, damage board) failed at the dry-run comparison. Every direct check failed too: H03, H05/H10, H01 and H13 on icons; H15/H16/H11 on roster; the H15/H16 skips; a second record on each of four cards in the rerun case; all four stub versions refused. The `--name anyone` case passed on `main`, as expected. The same run against the branch passed every case.
- **Done differently**: the which-copy line goes to stderr, so stdout keeps the line format `HEAL.md` gives. `heal-board.py` keeps its aligned `created:  ` stamp spacing, which the comparison ignores as the existing H17 case already did.
- **Done differently, smoke**: the old "heal defers" case touched an empty board copy and expected a refusal. That copy now has no version, so the stub-version cases replace it. The signature case's fixture card had a readable plain title, which heal v6 leaves alone, so it now carries a block-layout icon (H17).
- **Not changed**: `SKILL.md`, whose `heal-board.py` row still reads right. `skills/heal/`.
- **Not checked**: the full smoke run, left for merged `main`. The `lease` section, which only checks `heal-board.py`'s usage line for a non-board, a path this change does not touch. A board where the app wrote the v6 `.schema/` and `heal-board.py` defers to it in real use. The app healer's `RESERVED_NAMES` still lacks `anyone`; that is for the close.
- **Changelog sentence**: The skills' board repair now keeps values it used to drop, notes on the card what it replaced, and matches the app's own repair.
