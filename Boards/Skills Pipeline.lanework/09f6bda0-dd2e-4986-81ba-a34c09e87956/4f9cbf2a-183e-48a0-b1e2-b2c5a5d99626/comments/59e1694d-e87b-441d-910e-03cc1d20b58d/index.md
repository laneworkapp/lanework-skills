---
schema: 1
kind: comment
in-reply-to: 72feff62-1b1f-4e68-9ab9-082705109754
created:  {at: 2026-11-28T01:59:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-28T01:59:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: APPROVE.** The FIFO blocking finding is closed for every non-regular file I could make, and notes 1 to 5 hold as the lead ruled, with round 1's behaviour intact; 1 note.

- **Stance**: adversarial, because the fixer ran at opus and the diff writes persisted data that another program reads
- **Round**: 2 (scoped: the open blocking finding, the ruled notes, and the diff `c43c661f..fa49ebb0`)
- **Card**: [Scripts leave a plugin signature file in every board they write to](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4f9cbf2a-183e-48a0-b1e2-b2c5a5d99626)
- **Branch**: `board-signature` at `fa49ebb0`

**Blocking**: none.

**Notes**

1. `skills/lanework/scripts/sign-board.py @ fa49ebb0` "return f.read().decode(\"utf-8\")": one non-UTF-8 byte anywhere in the board's `.gitignore` leaves the board unsigned, because the decode fails before the seed line is looked for. This was already true at round 1, and it is safe (an unsigned board, exit 0). The app writes the seed in UTF-8, so this is out of scope unless a user's own edits are expected to carry other encodings.

**Checked**

- **Blocking 1, closed (OWN RUN)**: each case ran through `file-card.sh` on a throwaway board with the seeded `.gitignore`, bounded at 15 s. Every one returned in about 0.3 s with the control run's exit code (0), stdout (one line) and stderr. No signer process was left.
  - A FIFO at the path: left as a FIFO.
  - A Unix socket at the path: left as a socket.
  - A symlink at the path to a FIFO: replaced by a regular file, and the FIFO is untouched.
  - A symlink at the path to `/dev/null`: replaced.
  - A FIFO as the `.gitignore`, run through `sign-board.py` directly as the heal scripts call it: unsigned, exit 0, in under 3 s.
  - A symlink to `/dev/zero` as the `.gitignore`: unsigned.
  - A FIFO as the install record, and `/dev/zero` as the install record: signed, with no install facts.
  - I made no device node (that needs root). `/dev/zero` and `/dev/null` reached through links take the same branch.
- **The new open path broke nothing (OWN RUN)**:
  - A symlinked regular `.gitignore` still signs.
  - Skill folders symlinked the way users install them (`links/work` and `links/lanework` pointing at the checkout's folders) read the target's `plugin.json`, version `"0.11.0"`.
  - A symlinked `plugin.json` is read through.
  - A symlink at the signature's path to an outside file: the link is replaced and the outside file is unchanged.
  - A folder at the path: the folder is kept and no temp file is left.
- **Note 1 (OWN RUN)**:
  - A repeat run leaves the inode and mtime alone, and so does an old but well-formed `written`.
  - Each of these is rewritten to one UTC stamp: a deleted `written` line, `<stamp> extra`, a duplicated `written` line, a fullwidth digit in the stamp, and a trailing junk line.
- **Note 2 (OWN RUN)**: the file is always written, and only the bad key is left out.
  - Dropped: `9999-12-31T23:59:59-01:00`, `0001-01-01T00:00:00+01:00`, `+99:99`, `+14:01`, `+05:60`, a fullwidth digit, a bad scope, and a SHA ending in a newline.
  - Kept: `-14:00`, which converts to `14:00Z` the same day.
  - An entry with a NUL in its `installPath` is skipped, and the matching entry after it counts.
  - Non-UTF-8, malformed or list-topped records give no install facts.
  - No scratch path reached the file in any of the 13 records.
- **Note 3 (OWN RUN)**:
  - Signed: plain, CRLF, trailing blanks and tabs, no final newline.
  - Not signed: leading blanks, a commented line, non-UTF-8.
- **Note 4 (OWN RUN, a real `lanework-merge.py` pass)**:
  - The repo had a `UU` lane in `P.lanework`, a `UD` card in `D.lanework`, and a user-staged edit in `Q.lanework`.
  - `git ls-files --stage` before and after: P's stages 1 to 3 became stage 0, D's stages 1 and 2 became stage 0, and D gained a merge comment. Q's entry is the same.
  - `P` and `D` were signed, `Q` was not, and the pass exited 0.
  - A pass that only removes a path: REASONED. Every unmerged path has stage 1 to 3 entries, and a resolve drops them, so `comm -3` always lists its board.
- **Note 5**: `moved` is counted only after `move_in`, so a pass where every change was skipped signs nothing. REASONED; there is no hook to force the skip, as the fixer says.
- **Fail-before**:
  - The FIFO case: FIXER RUN on an archive of `c43c661f`. It agrees with my round-1 hang reproduction.
  - Spot-check (OWN RUN): I put round 1's `written` compare back into a copy of `fa49ebb0`'s writer. `tests/smoke.sh --only signature` then failed after 10 `ok` with "a drop written line was not rewritten", exit 1. Case 10 discriminates.
- **Round-1 behaviour still holds (OWN RUN)**: rewrite only on change; six concurrent writers all exit 0 with no temp files; a read-only board gives exit 0 and no file.
- **Blast radius**: 4 files: `sign-board.py`, `merge-board.sh`, `heal-descriptors.py` and `tests/smoke.sh`, as the fixer's record lists. `writes.md` and the README are unchanged, and their counts stay true (`check-sizes` passes).
- **Gates** (OWN RUN, worktree root at `fa49ebb0`):
  - `bash -n` OK on 16 shell files.
  - `py_compile` OK on the 3 Python files under Python 3.14 and the system 3.9.6, with the output outside the tree.
  - `check-refs: 262 references, 0 missing`
  - `check-sizes: 59 rows, 0 wrong`
  - `smoke: 120 passed (sections: heal_board, braces, merge, heal_descriptors, lease, signature)`, exit 0.
  - The worktree is clean, with no `__pycache__`.
- **Not checked**: the full smoke run (the lead's), a device node, the heal-descriptors skip path by a run, a real install record, and the app reading the file.
