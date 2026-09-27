# Traps

Commands that return a **plausible answer to a different question**: mostly a false zero or a silent success. Board-write traps: `lanework-boards/references/writes.md`.

## Shell

| command | actually |
|---|---|
| `grep -c` | exits **nonzero** on a 0 count: kills `set -e`, inverts `if` |
| `cmd && x` as a loop's or function's last line under `set -e` | false `cmd` → nonzero loop/function → silent exit. Use `if` |
| `cmd 2>/dev/null` on a sweep | hides the instrument's complaint about its own args. Never on a quoted number |
| short lowercase pattern | matches **inside** longer words; the false positive can point the wrong way |
| `cmd \| head` / `\| tail` | exit code is the **last** command's. Log + echo `$?`, or `pipefail` |
| `tool $VAR` under zsh | no word-splitting: one argument. Use an array |
| `xargs` on paths with spaces | splits the path. Loop, or `find -exec … {} +` |
| `log show` in zsh | a **builtin**, returns nothing. `/usr/bin/log`, whole-second `--start` / `--end` |
| filtering fswatch event paths | drops owner comments and card moves. Why: `pitwall/scripts/watch-board.sh` header |

## Git

| command | actually |
|---|---|
| `git checkout -- <file>` | restores from the **index**: on an uncommitted branch it deletes the fix. Revert with `cp` |
| `git diff main..HEAD` | diffs against a **moving** ref, reports the other side's commits as yours. Use `git merge-base` or a pinned sha |
| `git blame` | "who last touched", **never** "did it exist before" |
| `git grep -E` with `\b` `\s` `\d` | POSIX ERE has no shorthand classes: literals or nothing |
| `git -C <removed-worktree>` | no error: walks up, answers for the **shared** repo. Check `git worktree list` first |
| bare `git` with agents in play | answers from the inherited cwd. Always `-C` |
| `grep -r` at a root containing worktrees | multiplies counts by the worktree count |
| `git merge-base --is-ancestor A B && echo ok` | silent on failure; silence reads as pass. Voice the negative; exit >1 (128) is fatal |
| `git merge-tree --write-tree` | merge-order answers **read-only**: use instead of a trial merge |
