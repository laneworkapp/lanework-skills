---
schema: 1
kind: comment
created:  {at: 2026-11-27T22:46:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-27T22:46:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Built on `board-signature`: 16 writers sign a seeded board through one writer, and the new smoke section fails before the change and passes after.**

- **Commits**: `f4162f25` the writer (`sign-board.py`, `sign_board` in `lib.sh`, `writes.md` § Signature); `c3e740af` the call sites; `813a1ccd` the smoke section `signature`; `c43c661f` the README line and the `writes.md` count. The branch sits on `fb475e67`. Main's only newer commit is a board write, so no rebase.
- **Signed call sites (16 scripts, 19 calls)**: `file-card.sh`, `move-card.sh`, `post-comment.sh`, `post-ask.sh`, `label-card.sh`, `lease.sh` (4 calls: a fresh stake, a re-stake of its own lease, a release, a forced release), `file-question.sh`, `file-record.sh`, `settle-question.sh`, `file-ticket.sh`, `claim-ticket.sh`, `resolve-ticket.sh`, `merge-board.sh`, `heal-board.py --apply`, `heal-descriptors.py --apply`, `found-board.sh`.
- **Where each call sits**: after the landing write, and after the validator where the script runs one, so a validator failure (exit 1) leaves the board unsigned. `post-comment.sh` signs after its `--release` step. `resolve-ticket.sh` signs only when its release did not fail. `label-card.sh` with nothing to add writes nothing and signs nothing. The heal scripts sign only when `--apply` wrote a file.
- **Not signed**: lease renew, lease check, the timer, the readers, the lints, `commit-board.sh`, import, watch and the merge driver. Case 9 checks this.
- **Different from the card**:
  - `found-board.sh` gets its call but can never sign. It refuses any folder that is not empty, and a folder holding the seeded `.gitignore` is not empty. Case 7 shows the refusal.
  - `merge-board.sh` is handed a repo, not a board. It signs every board that had unmerged paths before the pass or staged paths after it, the same set `resolve` validates. It signs only when the pass exits 0.
  - The install record is matched on its `<name>@...` keys and the entry's `installPath`. The stamp is read with a regex, not `fromisoformat`, so a `.123Z` or `+01:00` stamp parses on the system Python 3.9 too.
  - A file is signed only when its `.gitignore` holds the line `.*.lanework-*`. A `.gitignore` without that line gets no signature.
- **Draft fixes**: the commit is 7 hex characters, lower case. The temp file is removed in a `finally` on every failure. All 16 writers are wired.
- **Accepted limitation**: when a script nests another writer, the loop in case 8 cannot tell whose call signed. This holds for `post-ask.sh` (`post-comment.sh` signs first) and `claim-ticket.sh` (`lease.sh stake` signs first). Case 9's guard covers those two. `resolve-ticket.sh` runs in the loop with no lease, so its own call is the only one.
- **Evidence, measured**:
  - **Fail-before**: the new `tests/smoke.sh` run on a `git archive` of `fb475e67` with `--only signature` exits 1 at case 1 with `file-card.sh on a seeded board left no .plugin.lanework-signature`.
  - **Pass-after**: the same section at `813a1ccd` prints `smoke: 9 passed (sections: signature)`.
  - **Mutations**, each on a scratch copy, each exit 1 in the section: removing the call from `file-record.sh` gives `file-record.sh wrote … and left no signature`. A call put inside `write_card` gives `the lease timer's renewals signed the board`. A 12-character commit fails case 4.
  - **Unwritable signature (case 5)**: two forms.
    - A folder at the signature's path. The temp file is written, `os.replace` fails with `IsADirectoryError`, the temp file is removed, and the folder is left as it was.
    - A read-only board folder. Creating the temp file fails with `PermissionError`.
    - In both, `file-card.sh` and `post-comment.sh` match a signed run's exit code, stdout and stderr, after the board path and the uuids are normalized, and the card and the comment land.
  - **Cost**: about 31 ms per no-change call, averaged over 10 calls on this machine. A board with no `.gitignore` returns in the shell before Python starts.
  - **Gate**: at `c43c661f`, `smoke: 270 passed (sections: static, founding, heal_board, discovery, plan, braces, lint_leases, post_comment, merge, label_kinds, filing_defaults, board_writes, cite_as, heal_descriptors, lease, signature)`, plus `check-refs: 262 references, 0 missing`, `check-sizes: 59 rows, 0 wrong`, `bash -n` on every changed script, and `py_compile` on the three Python files, with no `__pycache__` left. The log is `sigfix/gate.log` in the fixer's scratchpad.
- **Not measured**: the full `tests/smoke.sh`, which is the lead's run. A real install record was never read: every case reads a fake one under `mktemp`. The app reading the file.
- **Sample**, from a throwaway board with a fake install record and `CLAUDECODE=1`:

```yaml
---
schema: 1
kind: plugin-signature
name: lanework
version: "0.11.0"
installed: 2026-11-12T10:00:00Z
updated: 2026-11-20T08:30:00Z
commit: 1a2b3c4
scope: user
agent: claude-code
written: 2026-11-27T21:38:02Z
---
```

- **Changelog line (proposed)**: Lanework scripts now leave a small signature file in each board they write to, so the Lanework app can tell which plugin version is working the board.
