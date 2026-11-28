---
schema: 1
kind: comment
created:  {at: 2026-11-27T23:46:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-27T23:46:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: a FIFO at the signature's path hangs every board-writing script after its write lands; the privacy allow-list, the call sites and the rewrite rule otherwise hold, with 6 notes.

- **Stance**: adversarial, because the fixer ran at opus and the diff writes persisted data that another program reads
- **Round**: 1
- **Card**: [Scripts leave a plugin signature file in every board they write to](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4f9cbf2a-183e-48a0-b1e2-b2c5a5d99626)
- **Branch**: `board-signature` at `c43c661f`

**Blocking**

1. `skills/lanework/scripts/sign-board.py:132 @ c43c661f` "with open(target, encoding=\"utf-8\") as f:": the writer opens whatever sits at `.plugin.lanework-signature` for reading, with no regular-file check. When a FIFO sits there, `open` blocks for good, so the caller never returns. Done when says "a write still succeeds, with the same exit code and output, when the signature cannot be written", and the card says "never fails or blocks". Reproduction (OWN RUN, on a throwaway board with the seeded `.gitignore`): `mkfifo <board>/.plugin.lanework-signature; file-card.sh <board> Ideas Fifo --body t.md --model smoke`. The card landed, but after 8 s `file-card.sh` was still running and had printed nothing. Killing the signer's pid let it finish, and then stderr carried an extra `Terminated: 15` line from `lib.sh:216`. Any shell writer hangs the same way. The heal scripts wait 60 s, then go on (`timeout=60`). The install record read at `:74` "with open(path, encoding=\"utf-8\") as f:" has the same shape, but that file sits in the user's own config. The state is unlikely: git and the app never make a FIFO. The fix is cheap, and the card's promise is absolute. Fix: before each `open`, read the existing signature and the install record only when `os.path.isfile` (or `lstat` gives `S_ISREG`). Otherwise treat the signature as different and the record as missing. Add a smoke row with a FIFO at the path.

**Notes**

1. `skills/lanework/scripts/sign-board.py:101 @ c43c661f` "def unwritten(text):": `written` is stripped from both sides before the comparison, so an existing file whose `written` line was deleted, or holds any text (I tried `written: <stamp> extra`), counts as current and is left as it is. That breaks "always present: written", and a hand-put value in `written` stays in the file. Fix: rewrite unless the existing `written` line fullmatches the UTC stamp form.
2. `skills/lanework/scripts/sign-board.py:55 @ c43c661f` "t = t - off if z[0] == \"+\" else t + off" and `:86` "os.path.realpath(p) == root": an install stamp at the edge of the range (`9999-12-31T23:59:59-01:00`, `0001-01-01T00:00:00+01:00`) raises `OverflowError`. An `installPath` holding a NUL raises `ValueError`. Either one escapes to the top-level `except`, so no signature is written at all, where the rule says only that one key is left out. Nothing leaks and nothing fails. An offset such as `+99:99` is accepted and shifts the time.
3. `skills/lanework/scripts/sign-board.py:113 @ c43c661f` "seeded = PATTERN in (line.strip() for line in f)": `strip()` also accepts `  .*.lanework-*` with leading spaces, which git does not apply (`git check-ignore` said NOT ignored). It also accepts a `.gitignore` that later has `!.plugin.lanework-signature`. In both cases the board is signed and the file shows as untracked. CRLF, trailing spaces and a missing final newline are accepted, and git agrees on those. A commented `# .*.lanework-*`, a negated line and a BOM-prefixed line are refused. Fix: `rstrip()` only. The negation case is not worth handling.
4. `skills/merge/scripts/merge-board.sh:35 @ c43c661f` "git -C \"$TOP\" diff --cached --name-only -z | boards_of": this also signs a board whose only staged change is the user's own and that the pass never touched. I staged one edit in `Q.lanework` and stubbed the pass to exit 0: `Q.lanework` was signed. With the stub at exit 1, `merge-board.sh` exited 1 and signed nothing. Harmless, since the signature only says which plugin version is present. It differs from "each board the pass touched".
5. `skills/heal/scripts/heal-descriptors.py:591 @ c43c661f` "sign_board(board)": it signs even when every change was skipped with "changed while healing", so nothing was written. Harmless.
6. Nested writers sign on the inner writer's success, before the outer one's failure path. `post-ask.sh` exits 1 with "landed, but the card could not be restamped" after `post-comment.sh` signed, and `claim-ticket.sh` fails after `lease.sh stake` signed. In both a write did land, so the result is sane. It qualifies "never on a failure path". The fixer recorded the test side of this; the behaviour side is recorded here.

**Checked**

- **Correctness vs done-when**:
  - Shape: under system Python 3.9.6, a fake record plus `CLAUDECODE=1` gave the card's sample exactly, in its key order. Offsets and fractions were converted to whole-second UTC.
  - Privacy (OWN RUN, 16 hostile `plugin.json` values and 25 hostile install records): rejected were a version or name with a newline, a quote, a colon, `---`, ` # c`, a trailing newline, a U+2028, an Arabic digit, 70 characters, a non-string, a list or upper case. Rejected or left out in the record were a scope with a space, a `/`, upper case, a newline or a list; junk, malformed or space-separated stamps; a SHA that was short, non-hex, 65 characters, an int or ended in a newline; a non-dict `plugins`, a list at the top, malformed JSON and non-dict entries. With two matching entries the first one wins. No path, user name or host name reached the file in any case. A fullwidth digit in a stamp is converted to ASCII.
  - Repeat run: bytes, inode and mtime unchanged. A change to `written` alone does not rewrite. A corrupt file, or one with non-UTF-8 bytes, is replaced.
  - Symlink at the path: `os.replace` swaps the link for a regular file, and the outside target is untouched. A link to an outside file that already holds a current signature is left as a link. A dangling link is replaced.
  - A folder at the path, or a read-only board: exit 0 with the same output. Eight concurrent `file-card.sh` runs: all exit 0, the file is valid and no temp file is left.
- **Project conduct**:
  - Board writes and skill changes are in separate commits. Nothing about this repo's process ships under `skills/`, and no `lanework-agent-guide v` string sits under `skills/`.
  - `writes.md` § Signature is accurate, telegraphic and the only place the rule lives. The README line is user-facing. The counts are re-measured, and `check-sizes` passes.
  - No real path, user name or host name in the new test lines. `nopath` reads `id -un` and `hostname -s` at run time.
- **Both paths**:
  - Call sites: grepped every script under `skills/`. The 13 scripts that call `stamp_args_ok`, plus `merge-board.sh` and both heal scripts, all sign. The two other founders reach `found-board.sh`.
  - Unsigned writers: `lease.sh renew` and `check`, the timer, `watch-boards.sh` (it writes only its own state file) and `commit-board.sh`. The timer calls `write_card renew` directly and never `sign_board`.
  - Failure paths: no sign after a validator failure, a refused write or a lost lease (they exit 1 or 3 before the call). `resolve-ticket.sh` checks `RC` first.
  - `found-board.sh`: its call never fires, because the script refuses a non-empty folder. Smoke case 7 shows the refusal, and the call is harmless.
  - `sign_board` under `set -euo pipefail`: with no `python3`, with the writer missing, or on a missing board, it returns 0 with no output. `IFS` and the working directory are unchanged.
- **Fail-before**: FIXER RUN read from the thread, at `fb475e67` with the case 1 message. My own mutation: the guard in case 9 fires with `move-card.sh` once its call is removed. Case 8 covers the non-nested writers; case 9 covers `post-ask.sh` and `claim-ticket.sh`.
- **Test adequacy**: section `signature` in `tests/smoke.sh`, run in a subshell with its own EXIT trap like its neighbours. It uses throwaway boards and a fake record. No existing smoke board or fixture has a `.gitignore`, so the existing cases stay unsigned and unchanged.
- **Blast radius**: 21 files. That is the Scope table's list plus `lib.sh` and the new writer, with no unexplained churn.
- **Population**: 16 writers, 19 calls, re-counted from the diff. The guard's denominator of 13 matches my own grep.
- **Gates** (OWN RUN, worktree root): `bash -n` OK on all 16 changed `.sh` files. `py_compile` OK on the 3 Python files under both 3.14 and system 3.9.6 (`cfile` outside the tree, no `__pycache__`). `check-refs: 262 references, 0 missing`. `check-sizes: 59 rows, 0 wrong`. Smoke: `smoke: 90 passed (sections: braces, lease, signature)`, exit 0. The full run is the lead's.

**Hypotheses**, written before I tested the fixer's evidence record (comment `9cbc9ca4`). 1 of 9 held.

1. A symlink at the path is written through: refuted (`os.replace` swaps the link).
2. A FIFO at the path or at the install record hangs the caller: confirmed (Blocking 1).
3. Hostile `plugin.json` values reach the file: refuted (fullmatch allow-lists).
4. Stamps with offsets are converted wrongly: refuted. At the range edges the whole file is dropped (Note 2).
5. `sign_board` changes the caller's status, `IFS` or working directory: refuted.
6. `merge-board.sh` signs after a failed pass: refuted. It signs extra boards on success (Note 4).
7. The heal calls leave `__pycache__`: refuted (`-I`, and the writer runs as a script).
8. A board writer is missed: refuted.
9. The call-site guard does not discriminate: refuted by the mutation.
