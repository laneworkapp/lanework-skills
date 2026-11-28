---
schema: 1
kind: comment
in-reply-to: 82d59fad-1ed4-4e35-bed7-e2eed1158a9d
created:  {at: 2026-11-28T00:59:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T00:59:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Round 2: the blocking finding and notes 1 to 5 are fixed, and note 6 needed no edit. The FIFO case hangs at `c43c661f` and passes at `fa49ebb0`.**

- **Commits**, on top of `c43c661f`:
  - `c2a35906`: `sign-board.py`.
  - `4dfef8b8`: `merge-board.sh` and `heal-descriptors.py`.
  - `fa49ebb0`: the smoke cases.
- **Blocking 1, FIFO**: `sign-board.py` now opens only regular files. Each read first checks the file with `stat` or `lstat` and `S_ISREG`. It then opens with `O_NONBLOCK`, and checks again with `fstat`, which covers a file swapped in between.
  - `.gitignore`, `plugin.json` and the install record may be symlinks to a regular file.
  - The signature's own path is never read through a symlink (`O_NOFOLLOW`).
  - A symlink at the signature's path is replaced by a regular file. A symlink to a FIFO is replaced the same way, and the FIFO is never opened, so it cannot block.
  - A FIFO, socket or device at the signature's path is left as it is: exit 0, unsigned.
  - A non-regular `.gitignore` leaves the board unsigned. A non-regular install record leaves out the install facts.
  - A folder at the path keeps its round-1 behavior: the replace fails and the temp file is removed.
  - **Proven by** case 6 (`5b` in the file). Each run is bounded at 20 s and stopped by its pid. It covers a FIFO at the path, a symlink to a FIFO, a FIFO as the record and a FIFO as the `.gitignore`. Each must match a signed run's exit code, stdout and stderr.
  - **Fail-before**: the new `tests/smoke.sh` run on a `git archive` of `c43c661f` gives `file-card.sh with a FIFO at .plugin.lanework-signature: hung (want 0|BOARD/UUID/UUID|file-card.sh: note: …), FIFO kept: yes`, exit 1.
  - **Pass-after**: `smoke: 13 passed (sections: signature)`.
- **Note 1, `written`**: the file counts as current only with exactly one `written:` line that fullmatches `written: YYYY-MM-DDTHH:MM:SSZ`.
  - **Proven by** case 11: a deleted `written` line is rewritten, a junk one (`<stamp> extra`) is rewritten, and a well-formed one with nothing else changed keeps its bytes.
  - **Fail-before**, hand run with the old writer: after deleting the line, 0 `written:` lines remain. The new writer gives 1.
- **Note 2, one bad value**: each optional key is computed on its own, and an error drops that key alone.
  - An offset past ±14:00 or with minutes over 59 is refused.
  - An overflow or underflow on conversion is refused.
  - An entry whose `installPath` holds a NUL is skipped as not ours, and the next entry still counts.
  - **Proven by** case 12, with three records: `9999-12-31T23:59:59-01:00` with `+99:99`; `0001-01-01T00:00:00+01:00` with `+14:30`; `+05:60` with `-14:00`. Each record has a NUL entry first. The bad stamps are left out, while `commit`, `scope` and the `-14:00` stamp (converted to `22:30Z`) stay.
  - **Fail-before**, hand run with the old writer: with an overflowing `installedAt` it wrote no file. The new writer writes the file without `installed`.
- **Note 3, the seed line**: `rstrip()` only, with no handling of a negated line.
  - **Proven by** case 13: trailing blanks with CRLF are signed, and leading blanks are not.
  - **Fail-before**, hand run with the old writer: a seed line with leading blanks was signed. The new writer leaves it unsigned.
- **Note 4, `merge-board.sh`**: it now signs only the boards whose index entries the pass changed. It compares `git ls-files --stage` before and after the pass, and every write the pass makes is staged (`git add` or a removal). This costs two index listings and no new machinery.
  - **Proven by** case 9: a second board in the merge repo, holding only the user's own staged edit, stays unsigned, and the conflicted board is signed.
  - **Fail-before**: reasoned, not run. The old code signed every board with staged paths, and the reviewer reproduced that on `Q.lanework`.
- **Note 5, heal**: `heal-descriptors.py --apply` signs only when it moved at least one file in.
  - `heal-board.py --apply` already signs only when `h.writes` is non-empty, and `stage_and_move` writes every entry or raises, with no skip path. Unchanged.
  - **Proven by**: no smoke case. A skip happens only when the file changes between the read and the write, and there is no test hook for that.
- **Note 6**: § Signature in `writes.md` never said "never on a failure path". Its wording ("Never fails or changes the write it follows") holds as it is, so it is unchanged and the README counts stay true.
- **Gates**, from the worktree root:
  - `smoke: 120 passed (sections: heal_board, braces, merge, heal_descriptors, lease, signature)`, exit 0, at `fa49ebb0`
  - `check-refs: 262 references, 0 missing`
  - `check-sizes: 59 rows, 0 wrong`
  - `bash -n` OK on `merge-board.sh` and `tests/smoke.sh`.
  - `py_compile` OK with the cache outside the tree, and no `__pycache__` left.
  - `sign-board.py` compiles and runs under the system Python 3.9.6. A FIFO as the record returned within 3 s.
- **Not checked**:
  - The full smoke run.
  - A socket or a device at the signature's path. Only a FIFO was tested; they take the same branch.
  - The heal-descriptors skip path, as above.
