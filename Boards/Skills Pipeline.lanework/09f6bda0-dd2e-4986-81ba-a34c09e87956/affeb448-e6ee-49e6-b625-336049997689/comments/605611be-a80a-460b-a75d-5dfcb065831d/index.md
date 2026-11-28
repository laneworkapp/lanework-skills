---
schema: 1
kind: comment
in-reply-to: a90de76c-430a-4942-abcf-ae264eab9a71
created:  {at: 2026-11-28T05:03:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-28T05:03:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: APPROVE.** `heal-board.py` made the same call as the board's heal v6 on every board I built, apply, records and rerun included, and the which-copy and `--apply` safety checks behave as the card says; 0 blocking findings, 5 notes.

- **Stance**: adversarial, as the lead asked (a ~680-line port whose only guard is side-by-side parity)
- **Round**: 1
- **Card**: [heal-board.py lags the board healer, now at heal v6](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/affeb448-e6ee-49e6-b625-336049997689)
- **Branch**: `healer-v6` at `761c472d`, merge-base `3187e3cd`

**Blocking**: none.

**Notes**

1. `skills/lanework/scripts/heal-board.py:79 @ 761c472d` "this version or later wins; repo CLAUDE.md names the same number.": a line about this repo's process inside a shipped file, which the repo `CLAUDE.md` bars under `skills/`. Fix: drop the `repo CLAUDE.md` clause (the stamp's link to `HEAL_VERSION` already lives in `CLAUDE.md` and smoke).
2. `skills/lanework/scripts/heal-board.py:1499 @ 761c472d` "if os.path.isfile(own)": the which-copy line has two odd edges. OWN RUN on a throwaway board: a directory at `.schema/bin/lanework-heal.py` heals with this copy and prints no stderr line at all; a `chmod 000` copy whose line 2 reads `# lanework-heal v9` heals with this copy and prints "states no version, older than this copy's 6". The second follows the card's ruling (unreadable → the skills' own), but the word "older" claims something nobody read. Fix: a separate line for an unreadable copy or a non-file at that path ("could not read its version: healing with this copy").
3. Version parsing differs across the three readers. `heal-board.py`'s `board_copy_version` matches `# lanework-heal v([0-9]+)\s*`, so it accepts a CRLF or trailing-blank line 2; `tests/smoke.sh` (`BHV=$(sed -n '2s/^# lanework-heal v\([0-9][0-9]*\)$/\1/p'`) and `scripts/release.sh` (`hv()`, the same `sed`) do not. OWN RUN: a stub with `# lanework-heal v6\r\n` on line 2 makes `heal-board.py` exit 2 ("ships its own heal at version 6"), while smoke and `release.sh` would read no version: no drift note, no warning. The app writes LF today, so this is latent. Fix: strip a trailing `\r` and blanks in both `sed`s, or make the Python regex strict too.
4. `skills/lanework/scripts/heal-board.py:1438 @ 761c472d` "if len(posted) == 2 and posted[1] == body:": the rerun check compares the whole body, and the body names the script ("Run by `heal-board.py`"). An apply interrupted under one healer and finished by the other posts a second record. OWN RUN on my combo board: v6 `--apply`, card files put back, then `heal-board.py --apply`: cards `…0001`, `…0002` and `…0006` each held 2 records. v6 does the same the other way round, and the name in "Run by" is an accepted difference, so this is not a parity break. Fix, if wanted: compare bodies with the Run-by line normalised. That belongs in both healers, so it is an app note too.
5. Shared with v6, not a port divergence: both healers write through a card folder that is a symlink pointing outside the board. OWN RUN: a lane held `c…0009 -> <absolute path to a card in the seed board>`, and `--apply` on each copy healed the seed's card in place. The dry runs matched; the applies differed only because the first one had already healed the shared target. With a relative symlink inside the board, both matched (TREE SAME, RECS SAME). For the owner as an app note, if at all.

**Checked**

- **Correctness vs done-when**:
  - Same call as v6 (OWN RUN). A plain `diff` of `heal-board.py` against the v6 file on disk leaves only these differences: the header and docstring, the usage text, the `heal-board:` prefixes, `HEAL_VERSION`, `anyone` in `RESERVED_NAMES`, the `created:  ` stamp spacing, the Run-by name, `sign_board`, `board_copy_version` and the which-copy block. `comment_index` now skips leading blanks itself while v6's `key_comment` does it before the call; its one caller makes the two equivalent. Every rule body is the same code as v6's.
  - Parity boards (OWN RUN). I built 4 boards of my own under `mktemp -d` and healed a copy of each with each healer (dry run, then `--apply --name fixer --model test`, then a rerun). I diffed the stdout, every file outside `comments/` (stamp spacing aside) and every record body (Run-by aside). Dry run, apply output, tree and records were identical on all 4, and each rerun read `0 repairs in 0 files`. The boards seeded:
    - combo, 36 repairs in 8 files and 3 records: H02 (date-only and bare stamps), H03 on a lane (`icon: hammer` + `iconColor`) and on a card (a mapping + `iconColor`), H04 on the board and lane (skips) and on a card (a record), H05 (`kind: epic`, a bare glyph, `value:`, a bare string value, the `default` type), H07 to H11, H13 and H14 on one card with a root priority mapping carrying an extra subkey, unknown subkeys on the entry, its kind and its icon, H15 and H16 together, a block-form label list, a value with an unreadable rank, curly and escaped quotes and `ü` in titles, a `title: null` skip, a ` #` title skip, a non-scalar title skip, and a CRLF card;
    - no lanes: empty `labels: []` and `priorities: []`, `collapse-empty: ""`, and a board `iconColor: 7` (skip);
    - odd: `config.labels` as a mapping (skip), `priorities` as a scalar, a root `priority: [a, b]` (H12), a block/flow mixed label list (H17), a relative symlinked card, and a `chmod 000` card (both skip it with the same line; the line carries an absolute path, in both);
    - mix: a `text` kind recoloured on the board, a single kind with duplicate values and tied ranks, a lane with `card-defaults`, a root `component:`, a label with an unreadable colour, an empty-text entry, a numeric entry, an alien kind with a subkey, a pre-existing comment holding `modified-by` (H04 on a comment), H06 and an H17 stamp.
  - Earlier copy → skills' own; same or later → refused (OWN RUN, stub board healers): v5 and no version gave rc 0 and the one stderr line. v6, v7 and v10 (a numeric, not lexical, compare) gave rc 2, named, empty stdout. `v6beta`, a version on line 1 and an empty file gave rc 0 with "no version". `--ignore-board-copy` gave rc 0 and empty stderr. A symlink to the port itself gave rc 0 and no line. stdout keeps `<file>: Hnn <code> <what>` and the `N repairs in M files` footer in every case. The directory and unreadable edges are in note 2.
  - `--name anyone` → 64, nothing written (OWN RUN): `anyone`, `ANYONE`, ` anyone `, `anyone `, `healer`, `Board`, ` shortcuts`, `tracker` and `""` all gave rc 64, with the tree checksum unchanged. `--name` with no value fell to the `--model` refusal, rc 64. On a board that ships a v6 copy, `--name anyone` exits 2 first: still nothing written.
  - Signature (OWN RUN, a board with the seeded `.gitignore`): a dry run wrote no `.plugin.lanework-signature`, an apply with writes wrote one, and an apply with nothing to write did not.
  - Interrupted apply (OWN RUN through smoke `ok 21`, on both healers): no second record. The cross-healer case is note 4.
  - Drift note and warning (OWN RUN): `SMOKE_BOARD_HEALER` set to a v7 stub printed `note: the board's healer is at heal v7, ahead of heal-board.py's v6: …; the side-by-side heal cases are skipped`, and the section ended `smoke: 16 passed (sections: heal_board)` with no "(the same call…)" suffix. Without the variable (the worktree's committed v5 copy): `note: the board's healer is at heal v5, older than heal-board.py's v6: the side-by-side heal cases are skipped`, then `smoke: 16 passed (sections: heal_board)`. The `release_gate` case (v7 warns twice, v6 is quiet, the exit is unchanged) passed in my run. FIXER RUN only: the missing-file note.
  - `writes.md` § Healing names the later-wins rule, the ids and the rerun rule. A `git grep` under `skills/` finds the rule only there; `SKILL.md` links to it. The repo `CLAUDE.md` names `lanework-heal v6` and `HEAL_VERSION`.
- **Project conduct**: no `lanework-agent-guide v<N>` under `skills/`, no home path, user or host name in the diff, and paths are staged per commit (3 commits, plain messages). The one repo-process line in a shipped file is note 1. No "couldn't resolve X, so assume Y" shapes.
- **Both paths**:
  - The same board with and without a v6 copy reachable: smoke skips honestly. The skipped cases still run `heal-board.py`'s direct checks, their `ok` lines drop the "(the same call as the board heal v6)" suffix, and the damage-board parity `ok` is not printed at all, so a skip is never counted as a parity pass.
  - `lib.sh` loads `heal-board.py` by path (`Doc`, `Heal`, `definitions_of`, `flattened`, `matched`, `normalize_entry`, `canon`, `scalar`, `Plain`, `emit_key`, `config_labels`, `entry_of`, `numeric_rank`, `is_text`, `ParseError`): every name is still there, with the same signature as at the merge-base.
  - The filing sections that go through those names (OWN RUN, `--only label_kinds,compact_form,filing_defaults,board_writes,founding`) ended `smoke: 64 passed (sections: founding, label_kinds, compact_form, filing_defaults, board_writes)`.
- **Fail-before**:
  - OWN RUN: the branch's `tests/smoke.sh` and `CLAUDE.md` over `git archive main`, with `HEAL_VERSION = 6` added to `main`'s script in that scratch copy so the version check passes, and `SMOKE_BOARD_HEALER` set to the v6 file. `--only heal_board` ended `smoke: failed in section heal_board` at the new rule-id case (the old `title-quote unquoted: "Plain title"` lines).
  - OWN RUN: my parity harness pointed at `main`'s script on the combo board gave 191 differing lines against v6 (a quoted-title rewrite, an H06 addition where the roster defines priority, a missing `title reads as null` skip, and 37 vs 36 repairs). So the side-by-side comparison discriminates.
  - FIXER RUN, not repeated: each named side-by-side case failing on `main`.
- **Test adequacy**:
  - The new cases sit in `sec_heal_board` beside the existing H17 parity case and use its helpers' conventions.
  - Old assertions changed, each judged:
    - `title: "Plain title"` → `title: Plain title` and the two-line title-fold → `cmp` against the seed follow v6 H01 ("left exactly as written, whatever its quoting"). The damaged-board side-by-side case pins the same call against v6.
    - The removed "heal defers" case touched an existing copy of the repo's committed healer, which is v5 and so no longer defers. The which-copy stubs (v5 / none / v6 / v7) replace it and are stricter: exit code, message, path, empty stdout.
    - The signature fixture moved from a plain title (which v6 now leaves alone) to a block-layout icon (H17), so `heal-board.py` still makes a real write. "every writer signs" passed in my run.
    - No assertion was weakened beyond these.
  - The new `HV` versus `CLAUDE.md` stamp check is a good tripwire.
- **Blast radius**: 6 files from the merge-base, all named in Scope (`SKILL.md` unchanged, as the fixer said). `README.md` moves only the `lanework` row and `writes.md` count, and `check-sizes` passes. The 34-line comment file in `git diff main healer-v6` is `main` moving ahead (the fixer's record), not branch churn.
- **Population**: 4 own parity boards, 4 of 4 identical; 13 which-copy stubs and paths, all as described; 9 reserved or padded names, 9 of 9 refused with nothing written.
- **Gates (OWN RUN, from the worktree root at `761c472d`)**:
  - `bash -n` on `tests/smoke.sh` and `scripts/release.sh`: ok.
  - `py_compile` with `PYTHONPYCACHEPREFIX` outside the tree: ok, and no `__pycache__` left.
  - `/usr/bin/python3` 3.9.6 runs `-h`.
  - `check-refs: 262 references, 0 missing`.
  - `check-sizes: 59 rows, 0 wrong`.
  - `SMOKE_BOARD_HEALER=<main checkout v6 file> … --only heal_board,heal_descriptors,release_gate,usage_guard,headers,static,versions,signature` → `smoke: 48 passed (sections: static, heal_board, versions, headers, release_gate, heal_descriptors, usage_guard, signature)`, with `ok 17` to `ok 21` carrying "(the same call as the board heal v6)" or the damage-board parity line.
  - `--only heal_board` without the variable → the v5 note, then `smoke: 16 passed (sections: heal_board)`.

**Hypotheses**, written before reading [the fixer's record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/affeb448-e6ee-49e6-b625-336049997689/a90de76c-430a-4942-abcf-ae264eab9a71). 1 of 6 held, and only as a note.

1. Rules the fixer did not seed (H02, H04, H12, H14, H17 combinations) diverge: refuted. The rule code is identical to v6, and 4 boards matched.
2. The version compare is lexical, so v10 counts as less than v6: refuted, rc 2.
3. A garbage, empty or unreadable board copy crashes the port: refuted. It heals with the "no version" line; the wording is note 2.
4. Records post on a refused or dry run, or the signature fires without a write: refuted.
5. The smoke skip path counts as a parity pass: refuted.
6. The record dedupe is fragile: held, but only across healers (note 4).

**Not checked**: the full `tests/smoke.sh` (I ran 13 of its 19 sections; the full run is the fixer's claim and the lead's merged-`main` gate); the `lease`, `plan`, `merge`, `cite_as`, `plugin` and `import` sections; a real board whose `.schema/` the app wrote, opened in the app; `release.sh` run for real (only its smoke case); the missing-file note in smoke.
