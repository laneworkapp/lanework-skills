---
schema: 1
kind: comment
in-reply-to: 605611be-a80a-460b-a75d-5dfcb065831d
created:  {at: 2026-11-28T05:06:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T05:06:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Notes 1 to 3 are taken on `healer-v6`, head `fe293fc7`, and the gate sections pass.**

- **Commits**: `ce2a46eb` takes the three notes. `fe293fc7` fixes one check in the new smoke case: it compared a path that smoke's scratch directory spells with a double slash, so it now matches the line by its shape.
- **Note 1**: the "repo CLAUDE.md" clause is gone from the `HEAL_VERSION` comment. A grep of the branch's added lines under `skills/` for smoke, `CLAUDE.md`, repo, pipeline, release, fixture, lead and fixer finds no other mention of this repo's files or process. One older line on `main` remains: `load_suggested`'s docstring says "smoke asserts the embedded copy equals the rows". It predates this card and is left as it was.
- **Note 2**: a path that is not a regular file is never opened, and that includes a directory, a FIFO or a dangling symlink. That case, and a file that can't be read, now print their own stderr line: `could not read the version of this board's own heal, "<path>": healing with this copy`. A readable file that states no version keeps the old line. `writes.md` § Healing says "unreadable" too, and the README word counts moved by one.
- **Note 2, case**: the which-copy smoke row gains a directory at the path and a mode-000 copy stating v9. The mode is restored before any check runs, and the sub-case is skipped with a note when running as root. Against the previous head `761c472d`, the directory printed no line and the mode-000 copy printed "states no version, older than this copy's 6". The branch prints the new line for both.
- **Note 3**: there is now one reading everywhere: line 2, exactly `# lanework-heal v<digits>` once trailing blanks and a CR are stripped. The Python strips the same characters as `[[:space:]]` and then does a full match. The `sed` in `tests/smoke.sh` and in `scripts/release.sh` hv() strips `[[:space:]]*$` first.
- **Note 3, cases**: the which-copy row gains a CRLF line 2 at v6 with a trailing blank, which is refused and named. The release-warning case gains a CRLF v7 stub, which warns for both the working tree and HEAD. The old `sed` printed nothing for a CRLF line 2.
- **Gates**: `bash -n` passes on `tests/smoke.sh` and `scripts/release.sh`. `py_compile` passes with the cache outside the tree, and no `__pycache__` is left. `/usr/bin/python3` runs `heal-board.py -h`. `check-refs: 262 references, 0 missing`. `check-sizes: 59 rows, 0 wrong`.
- **Smoke**: run with `SMOKE_BOARD_HEALER` set to the v6 file in the main checkout, `smoke: 47 passed (sections: static, heal_board, versions, headers, release_gate, usage_guard, signature)`. The side-by-side cases ran: 5 rows name the board heal v6.
- **Slip**: the first gate run at `ce2a46eb` failed on that path check. Smoke kept its own scratch directory under the system temp folder, with the stub copy's mode already restored to 644. I left it as it is.
