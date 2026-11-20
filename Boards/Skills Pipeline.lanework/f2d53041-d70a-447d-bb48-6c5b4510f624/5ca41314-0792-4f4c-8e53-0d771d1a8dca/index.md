---
schema: 1
kind: card
title: "commit-board.sh drops the owner's staged version of a path when a pre-commit hook fails"
order: 14336
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T13:35:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T17:55:04Z}
---
When a pre-commit hook fails, `commit-board.sh` commits nothing but still runs `git reset` on its named paths, so the owner's staged version of a named path is thrown away. The fix is to reset in the exit trap only once HEAD has actually moved and the lock is still ours. Five smaller edges of the same helpers, found in the same review of [the helpers card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f), ride along as items 3 to 6.

## Today

Checked on `main`. Line numbers are `work/scripts/commit-board.sh` unless named. None of these helpers is in a release yet: they first ship in 0.9.0.

| # | where | what happens | how sure |
|---|---|---|---|
| 1 | `:151` sets `HEAD0=1` before `git commit` at `:152`; the trap at `:70` resets whenever `HEAD0` is set | a pre-commit hook fails, `set -e` exits 1, and the trap runs `git reset -q -- <paths>`. The owner's staged version is gone; the work tree is intact. The script prints nothing of its own about the failure | measured |
| 2 | `:70`, the trap reset | it runs even after `mine` (`:156`, `:160`) found the lock lost. At those points the index was already synced at `:153` or `:162`, so the reset adds nothing, and it can collide on `index.lock` with the run that holds the lock now | read, not run |
| 3 | `:144` | every named path skipped (a glob read literally, a typo): prints `nothing to commit` and exits 0. Only stderr says "skipped". Smoke asserts this exit 0 today (`tests/smoke.sh:1905`) | measured |
| 4 | `:47`, `os.path.realpath` on the whole path | a symlink inside the work tree has its target committed, not the link | measured |
| 5 | `${2:?}` in `file-card.sh`, `move-card.sh`, `post-ask.sh`, `post-comment.sh` (and `${1:?}`, `${2:?}` for `post-comment.sh`'s positionals, `:22`) | a flag with no value, or `post-comment.sh` with no arguments, exits 1. Each header documents exit 2 for a bad flag. `commit-board.sh --trailer` already exits 2 | measured on all four |
| 6 | `tests/smoke.sh:1868`, the kill-mid-push loop | the SIGKILL leg skips the trap, so its `work-commit.*` stage folder stays in the real `TMPDIR` on every smoke run | measured: 55 such folders in this machine's `TMPDIR` |

Measured reproduction of 1, in a throwaway repo under `mktemp -d` with `.git/hooks/pre-commit` set to `exit 1`:

```sh
echo v1 > b/a.md; git add b/a.md; git commit -qm init
echo v2 > b/a.md; git add b/a.md; echo v3 > b/a.md   # staged v2, disk v3: status MM
commit-board.sh msg b/a.md                            # exit 1, no commit
git show :b/a.md                                      # v1: the staged v2 is lost; status " M"
```

## Change

Items are independent. 1 is the one that changes what the owner has staged; 2 rides with it because it edits the same trap line. 3 to 6 could each be dropped or split off without touching 1.

1. **Reset only when HEAD moved.** `skills/work/scripts/commit-board.sh`: replace `HEAD0` with `PRE` (HEAD's sha, taken just before `git commit`) and `LANDED` (set when `git commit` returns 0). The trap resets when `LANDED` is set, or when `PRE` is set and HEAD is no longer `PRE`; the second covers a SIGTERM that lands while `git commit` is finishing. A failed `git commit` exits 1 with `commit-board.sh: git commit failed (a pre-commit or commit-msg hook?); nothing committed, the index untouched`. Update the header: a failed commit is in the exit-1 list, and the trap note says it syncs only once a commit landed. Prototyped in a copy: the hook case keeps the staged v2 and status stays MM; with the hook removed, the next run commits and syncs as before. Today's `tests/smoke.sh` passes on that copy with items 1 and 2 applied (measured: 250 passed, the SIGKILL and SIGTERM cases included).
2. **Reset only while holding the lock.** Same trap line: add `own &&` to the condition. Every lost-lock exit comes after a `sync_index`, so nothing is lost by skipping it.
3. **Exit 1 when every named path was skipped.** `:144` prints `commit-board.sh: none of the named paths is on disk or in HEAD; nothing committed` and exits 1. `nothing to commit` with exit 0 stays for named paths that exist but have no changes. Header updated. `tests/smoke.sh:1905` changes to expect exit 1 and HEAD unchanged.
4. **Commit the link, not its target.** `:47` resolves only the parent: `realpath(dirname(normpath(abspath(p))))` joined with the basename, which is what `git add` does with a symlink. The root and outside-the-tree refusals keep working: `.` still resolves to the top.
5. **Exit 2 on a missing value.** `skills/lanework/scripts/lib.sh` gains `need_value` (`need_value "$@"` before each `X="$2"; shift 2`): with no second argument, or an empty one, it prints `<script>: <flag> needs a value` and the usage, then exits 2. The four scripts use it in place of every `${2:?}`. `post-comment.sh:22` gets the `[ $# -ge 2 ] || { usage; exit 2; }` guard the other three already have.
6. **Smoke leaves no stage folder.** `tests/smoke.sh`: the kill loop runs `commit-board.sh` with `TMPDIR="$G/tmp"` (made first), inside the throwaway folder that smoke already removes.

Tests, all in `tests/smoke.sh` beside the existing commit-board cases:

- 1: a `pre-commit` hook that exits 1. Stage v2 of the card file, write v3 to disk, run `cb`. Expect exit 1, HEAD unchanged, `git show :<path>` = v2, `git status --porcelain -- <path>` = `MM <path>`, stderr naming `git commit failed`. Remove the hook, run `cb` again: it commits, and the index matches HEAD.
- 3: the glob case expects exit 1 and HEAD unchanged; a new line checks an unchanged real path still prints `nothing to commit` with exit 0.
- 4: a symlink to the card file, committed by name: `git ls-files -s` shows mode `120000` for the link and the target is not in the commit.
- 5: each of the four scripts with a value-taking flag last and no value, and `post-comment.sh` with no arguments: exit 2.
- 6: after the loop, `$G/tmp` holds no `work-commit.*` folder before smoke removes it; nothing new appears in the real `TMPDIR`.

## Not in scope

- A hook that rewrites files on disk (a formatter) before failing. The script leaves the work tree alone either way.
- The SIGKILL window between `git commit` returning and `sync_index`, which the header already documents.
- Retrying or bypassing a failing hook. A failed hook stays a stop, exit 1.
- Cleaning up the stage folders smoke has already leaked on this machine.

## Risks

- Item 3 turns an exit 0 into exit 1. A caller that names only a path filed and moved since HEAD now sees a failure. No script under `skills/` calls `commit-board.sh`; agents call it by hand, and the new message says what happened.
- Item 5 adds a function to `lib.sh`, which every script sources. A name clash is the risk; `need_value` is not taken today.
- Item 1 adds a `git rev-parse` in the trap. It runs only after a commit was attempted.

## Done when

- `tests/smoke.sh` passes with the new and changed cases above. The case for 1 prints `ok commit-board.sh: a failed pre-commit hook commits nothing and leaves the owner's staged version in the index`.
- In a throwaway repo with `.git/hooks/pre-commit` = `exit 1`, staged v2 and disk v3 on `b/a.md`: `commit-board.sh msg b/a.md` exits 1, then `git show :b/a.md` prints `v2`.
- `grep -n 'HEAD0\|\${2:?\|\${1:?' skills/work/scripts/*.sh` prints nothing.
- `ls "$TMPDIR" | grep -c work-commit` is the same number before and after a smoke run.

Bump: patch. It rides 0.9.0, and the existing 0.9.0 entry about the helpers covers it.

## Decided

Ruled by the owner on this card, 2026-11-20: **0.9.0 is held until item 1 is built and merged.** It is the first release to ship `commit-board.sh`, and item 1 is the only bug here that loses the owner's work. Not taken: cutting 0.9.0 now and shipping this as 0.9.1.

Items 2 to 6 ride the same build unless struck at review; only item 1 holds the release.
