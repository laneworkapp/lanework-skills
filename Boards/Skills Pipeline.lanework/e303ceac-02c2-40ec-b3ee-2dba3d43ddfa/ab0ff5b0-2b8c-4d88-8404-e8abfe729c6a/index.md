---
schema: 1
kind: card
title: "commit-board.sh leftovers: staged entries on a retry, unbounded timeout value, uncovered rules, tty prompt"
order: 97280
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T19:23:32Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
`commit-board.sh` stops losing an owner's staged entries when its first try was the push-only path, refuses a push bound that macOS cannot honour, and gives its push no terminal so a credential prompt fails at once instead of waiting out the bound; four untested safety behaviors get smoke cases.

## Problem

1. **Staged entries not saved when try 1 was push-only.** Reproduced on a throwaway repo with a bare origin. Setup: `HEAD` one commit ahead of `origin/main`, the owner has staged `vowner` for the card file and put `v1` (equal to `HEAD`) back on disk (`git status` shows `MM`). A `pre-push` hook rejects every push and, on the first one, rewrites the file on disk to `v2`. Run `commit-board.sh --push msg <file>`. Try 1 has nothing new to commit, so it pushes the earlier commit (the `AHEAD` path) and `save_owner` is never called. Try 2 sees `v2`, commits, and `[ "$try" -gt 1 ] || save_owner` skips the save. After the fifth rejection the script exits 1 and prints `the index restored to what was staged before the run`, but `git show :<file>` prints `v1`, not `vowner`, and `git status` shows ` M`. The owner's staged entry is gone and the message says otherwise. Reaching it needs a named file to change on disk during the retry window, so it is rare, but the claim in the message is wrong when it happens. Reasoned from `skills/work/scripts/commit-board.sh` line 251 and confirmed by the run above.
2. **A huge bound disables the bound.** Measured: on this macOS, `perl -e 'alarm N; print alarm(0)'` returns `N` for 100000000 and `0` for 1000000000, 2147483647 and 99999999999 (and warns `alarm() with negative argument` from 2147483648 up), so `alarm` sets nothing. The value check at line 73 accepts any run of digits, so `LANEWORK_PUSH_TIMEOUT=99999999999` passes and the push is unbounded. The real ceiling is 100000000, found by bisection, which is over three years; no sensible bound is near it.
3. **Four safety behaviors have no smoke case.** Checked against the current `tests/smoke.sh`, which signals the script only by its own pid (held until the push returns), so the wrapper's handlers never fire in any case.
   - Forwarding of INT, TERM and HUP to the push's group (line 159). Reproduced by hand: with a `pre-push` hook that runs `sleep 30`, sending TERM or HUP to the perl wrapper's pid ends the run in 3 s, the hook's `sleep` gone, and the retry pushes. INT does the same once the run is started with SIGINT at its default (a `( cmd ) &` job in a script ignores INT, and the push inherits that, so a test must start the run through `perl -e '$SIG{INT}="DEFAULT"; exec @ARGV'`; without that the INT run sat for the full 60 s bound). Works today, untested.
   - A git that itself exits 124 not reading as a timeout (line 162). Reproduced: a `git` wrapper on `PATH` that exits 124 for the first `push` gives `push rejected (try 1 of 5); un-committing ...` and then a successful retry, with no `timed out`. Works today, untested.
   - The sweep's live-pid guard (line 150). Reproduced: with saved files `saved.<live pid>.AAAAAA` (dated 2020), `saved.<dead pid>.BBBBBB` (2020) and `saved.<dead pid>.CCCCCC` (fresh), a run leaves `AAAAAA` and `CCCCCC` and removes `BBBBBB`. Works today, untested.
   - The non-fatal `rm` in `release` (line 118). Reproduced: a `pre-push` hook that does `chmod a-w .git` makes both `rm`s fail with `Permission denied`, yet the run exits 0 with the commit on origin. Works today, untested. I could not run the mutation (the `|| true` removed) because the harness refused the `sed`; a failing command inside an `EXIT` trap under `set -e` normally ends the trap early with its status, so the case should fail without the guard.
4. **A tty credential prompt waits out the bound.** Not reproduced as a real prompt (by instruction); reasoned from `skills/work/scripts/commit-board.sh` lines 156 to 163. The wrapper puts `git push` in its own process group, which is a background group of the terminal, so a read from `/dev/tty` raises SIGTTIN and stops it. The wrapper's `waitpid` does not watch for stops, so nothing notices until the alarm kills the group after `LANEWORK_PUSH_TIMEOUT` seconds, and the run then says `push timed out ... run --push again`, as if the push might have landed. Measured the precondition: under a pty (`script -q /dev/null commit-board.sh --push ...`) a `pre-push` hook can open `/dev/tty` (`tty-open`); with no pty it cannot. It applies to ssh passphrase and host-key prompts as well as git's own HTTPS prompt. The card's `GIT_TERMINAL_PROMPT=0` option covers only git's own prompt.

## Change

1. `skills/work/scripts/commit-board.sh`: keep a `SAVEDONE` flag next to the other state variables (line 100); at line 251 replace `[ "$try" -gt 1 ] || save_owner` with `[ -n "$SAVEDONE" ] || { save_owner; SAVEDONE=1; }`, and keep the comment saying why it is once (later tries start from the restored index). Nothing else in the file changes for this item.
2. `skills/work/scripts/commit-board.sh`: add a ceiling to the check at line 73: after the digit test, reject a value longer than 5 digits or above 86400 (one day) with the same exit 2 and a message saying `a whole number of seconds from 1 to 86400`. Update the header sentence at line 18 to match. Checking the length first keeps the numeric test from overflowing on a 20-digit value. Do not add an `alarm` return check in perl: its return value cannot tell a failed set from none.
3. `tests/smoke.sh`: add the four cases listed under Verified. No script change.
4. `skills/work/scripts/commit-board.sh`: in `push_bounded`, start the push's child with `POSIX::setsid()` instead of `setpgrp(0, 0)` (add `-MPOSIX` to the perl command) and delete the parent's `setpgrp($pid, $pid)` line. A new session has no controlling terminal, so `/dev/tty` opens fail with `Device not configured` and git or ssh fails at once, which the script already treats as a rejected push (un-commit, up to 5 tries, the error shown), not a timeout. The child is still a group leader, so `kill -SIG, -$pid` still reaches the hook's children. The parent's `setpgrp` must go: it races the child's `setsid`, and when it wins the child is a group leader and `setsid` fails. Make the INT, TERM and HUP handlers `kill $_[0], -$pid or kill $_[0], $pid` so a signal in the instant before the child's `setsid` still lands. Rewrite the header text at lines 17 and 41 where it says "its own process group" to say its own session, no terminal, with the one-line reason. Do not add `GIT_TERMINAL_PROMPT=0`: one mechanism, and it would leave ssh prompting.

## Verified

All in the existing commit-board block of `tests/smoke.sh`, on its throwaway `$G` repo and origin, with `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1`. Each fails without its fix.

1. **Staged entries across a push-only first try.** Commit one change locally so `HEAD` is ahead, stage a different version of the named file and put the `HEAD` version back on disk, install a `pre-push` hook that rewrites the file on disk on its first call and exits 1 every time. Run `--push`. Assert exit 1, `git show :<file>` equals the staged version, `git diff --quiet` shows the disk version unstaged, `HEAD` unchanged, and no saved file left. Without the fix the index holds the `HEAD` version.
2. **The ceiling.** `LANEWORK_PUSH_TIMEOUT=86401`, `100000000` and `99999999999` each exit 2 with no commit and no lock left; `86400` with a plain push exits 0 and pushes. Without the fix the first three run unbounded; the case stops them by the hook not running (a marker file the hook would touch must be absent).
3. **The four untested behaviors.**
   - Signal forwarding: a `pre-push` hook that records its parent's pid and runs a foreground `sleep 30`; launch the run with `LANEWORK_PUSH_TIMEOUT=60` through `perl -e '$SIG{INT}="DEFAULT"; exec @ARGV'`, find the wrapper as the hook's grandparent, send it TERM, then HUP, then INT, one run each. Assert each run ends in under 15 s with no `timed out`, and the `sleep` pid is dead. Do not signal a process group in smoke. Without the handler line the run waits out the 60 s bound.
   - A git that exits 124: a `git` wrapper on `PATH` (as the existing `WB2` case does) exits 124 on the first `push` only. Assert the output says `push rejected (try 1 of 5)`, not `timed out`, and the second try pushes with exit 0.
   - The sweep: create the three saved files above with `touch -t`, run one plain commit, assert the live-pid one and the fresh one remain and the dead old one is gone.
   - Non-fatal cleanup: a `pre-push` hook doing `chmod a-w` on the git dir; assert exit 0 and the commit on origin; `chmod u+w` and remove the leftover lock and saved file in the case's cleanup.
4. **No terminal for the push.** Run the script under `script -q /dev/null` (BSD syntax, fine on `macos-latest`) with a `pre-push` hook that writes `tty-open` or `tty-closed` according to whether `exec 3<>/dev/tty` succeeds. Assert `tty-closed` and a good push. Without the fix the hook records `tty-open`. This opens the device but never reads it, so no prompt is provoked. The existing timeout case already proves the hook's child is still killed at the bound; add nothing for that.

## Done when

- `bash -n skills/work/scripts/commit-board.sh` passes.
- In a throwaway repo, the item 1 setup ends with `git show :<file>` printing the staged text and a message that is true.
- `LANEWORK_PUSH_TIMEOUT=99999999999 commit-board.sh --push ...` exits 2 and names the 1 to 86400 range.
- Under `script -q /dev/null`, a `pre-push` hook cannot open `/dev/tty` and a push still lands.
- `grep -n 'process group' skills/work/scripts/commit-board.sh` shows no stale claim that the push has a terminal.
- The new smoke cases pass in `tests/smoke.sh` (run on a throwaway board only, never the Skills Pipeline board), and each fails when its fix is reverted.

## Risks

- A hook or credential helper that needs a terminal can no longer prompt during the push. It could not usefully do so before either (stopped, then killed at the bound), so nothing that worked is lost; the failure is now fast and counts as a rejected push, so a missing credential costs five quick tries and about ten seconds of sleeps before exit 1.
- `setsid` and the signal handlers sit in the safety-critical path. The existing kill and timeout cases cover most of it, and the new forwarding case covers the rest; run those before release.
- The `script` pty case is BSD `script`, as in the macOS-only CI. A Linux runner would need different syntax.
- The new cases add about 25 s to smoke (item 1 needs all five rejections, as the existing five-failure case does).
- The 86400 ceiling is a policy choice; the hard limit is 100000000 on this macOS.

## Recommendation

Build all four items. Items 1, 2 and 4 are real defects with cheap fixes. Item 3 is worth all four cases: they cover signal forwarding, cleanup and the sweep, which are the behaviors that keep the lock and the owner's index safe, and each takes a few lines on the existing scaffolding. Item 4 should use the new session, not `GIT_TERMINAL_PROMPT=0`, because it also fixes ssh prompts and needs no new variable.
