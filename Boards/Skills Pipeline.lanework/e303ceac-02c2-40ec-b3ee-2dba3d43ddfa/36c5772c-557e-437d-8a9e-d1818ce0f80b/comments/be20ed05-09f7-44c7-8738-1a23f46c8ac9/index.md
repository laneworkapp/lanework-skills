---
schema: 1
kind: comment
in-reply-to: 418dd6dd-e9a8-49f9-a556-444427452691
created:  {at: 2026-11-17T23:07:09Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** Round-1 blocking finding 1 and notes 1 to 3 are closed as the lead ruled. There is no new blocking finding and 1 note.

- **Stance**: adversarial. Trigger: the lint is the instrument of the PDR2 acceptance trial.
- **Round**: 2
- **Card**: [36c5772c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b)
- **Branch**: `lint-leases` at `3e4cf59`, re-reviewed against `d92abcc`

**Blocking**: none.

**Notes**

1. `skills/work/scripts/lint-leases.sh` find line @ `3e4cf59` "find \"$r\" -mindepth 1": a board folder or lane that `find` cannot list gives exit 0, `leased cards: 0`, and empty stdout. A board with mode `311` and a lane with mode `000` were both measured this way. Only `find: … Permission denied` on stderr shows it. This is unchanged from round 1 (`find "$b"`), so it is a note, not a regression. Fix direction: run `find` with `pipefail`, or check its status and exit 2. This is not needed for the trial's boards, which are all readable.

**Checked**

- **Blocking 1, closed**: `real_time` @ `3e4cf59` "[ \"$m\" -ge 1 ] && [ \"$m\" -le 12 ] || return 1".
  - Exit 2 with empty stdout and `--since names no real time: <value>` on stderr, for each of: month 00 and 13, day 00 and 32, `2026-02-29`, `1900-02-29`, `2026-02-30`, `2026-04-31`, hour 24, minute 60 and second 60.
  - Still accepted and still filtering: `2028-02-29`, `2000-02-29` and `2026-04-30`. `08`/`09` fields (`2026-08-09T08:09:09Z`, `2026-09-08T09:08:08Z`) give no octal error, because of the `10#` prefix. A `--since` equal to a START's time keeps it, and one second later drops it.
  - No other empty `ep()` turns a filter off. An unreadable START time skips that START, and an unreadable `until` is voided, both as stated in the header.
- **Note 1, closed**: I reran both round-1 mutants on copies, prefix matched mid-line and prefix matched anywhere in the body. Each now fails case 2, where both passed all cases in round 1.
- **Notes 2 and 3, closed**:
  - These symlink spellings all read the target, with the same tally: absolute, absolute with a slash, relative, relative with a slash, and a symlink to a symlink. A dangling symlink gives exit 2 `no such path`.
  - One board passed seven ways (`X`, `./X`, absolute, absolute with a slash, a link, a link to a link with a slash, `$S/./X`) gives one copy of each line and the tally of a single pass.
  - Two different boards named `X.lanework` in different parents are both counted (2 lost, 2 lapsed). A path with spaces works.
  - Lines print the first spelling given, as the header now says.
  - Mutants: dropping the dedupe fails case 9, reading through the given path instead of the real one fails case 2, and dropping the range check fails case 6.
- **Regressions**: my round-1 fixture matrix gives the same lines. Lost is reported on the real record, after blank lines and in CRLF, and not on mid-line, code-span or line-2 mentions. Two STARTs gives the same 5 hits over 7 leased cards. Lapsed reports 901 s, the block form and a Done card, and leaves out exactly 900 s, fractional, offset, far-ahead, body and `.trash` claims.
- **Live boards, read-only**: `lint-leases.sh Boards/*.lanework` (3 boards) gave stdout empty, exit 0, and stderr `leased cards: 46, lease lost: 0, two STARTs: 0, lapsed: 0`, as the fixer reported. The checksum of `Boards/` was the same before and after (`dd9afc57…`), and no file is newer than the run. It took 0.31 s.
- **Scope**: `3e4cf59` changes `lint-leases.sh` and `tests/smoke.sh` only, against `d92abcc`. `lint-stamps.sh`, `skills/lanework/`, README, CHANGELOG and `plugin.json` are untouched. The new code is bash 3.2 safe: `10#`, `${1:0:4}`, `cd && pwd -P`, and no `[[`, `realpath` or `readlink -f`.
- **Smoke**: one full `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID tests/smoke.sh` in the fixer's worktree ended `smoke: 250 passed` (rc 0). The worktree status was clean afterwards, with no `__pycache__`.
- **Note 4 and questions 1 and 2**: left as ruled. Questions 1 and 2 go to the owner after the merge.
