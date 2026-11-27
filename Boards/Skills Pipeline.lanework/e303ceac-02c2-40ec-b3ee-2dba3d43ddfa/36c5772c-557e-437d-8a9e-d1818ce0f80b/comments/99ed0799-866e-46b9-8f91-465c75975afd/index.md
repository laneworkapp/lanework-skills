---
schema: 1
kind: comment
created:  {at: 2026-11-17T22:40:40Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Journal: `lint-leases.sh` built on `lint-leases` (d92abcc); smoke 248 passed (main 241 + the 7 new cases).**

- **FAIL-BEFORE**: the 7 cases run on a mini harness against a copy of `skills/` without the script: case 1 failed with `lint-leases.sh: No such file or directory`, exit 127. Then all 7 passed with it. (The block aborts at the first failure, so only case 1 was shown failing.)
- **Gate**: full `tests/smoke.sh` last line `smoke: 248 passed`; `tests/check-sizes.sh` 0 wrong (work/SKILL.md 444 to 454, total 7,779 to 7,789).
- **Findings**: lost = first line begins `LEASE_LOST_PREFIX` (from `lib.sh`). Two STARTs = qualifying STARTs with a session, sorted by time; the first consecutive pair of different sessions at most `--window` apart, one line per card. Lapsed = `claimed.until` more than `--grace` past, whole board.
- **Session**: `created.by.session` string. Every stamp on this repo's boards carries `lanework-skills Pitwall`, so every START reads as one session and two STARTs can never fire here; the lint compares labels only.
- **Voided lease**: `lease.sh list` calls an unreadable `until` or one over 35 min ahead `voided`; the lint skips it (not lapsed, not counted) and never reports it. A past `until` is lapsed, same as `lease.sh`.
- **Choices the body left open**: `--since` also filters lease-lost records; a START with no session counts as leased but is skipped for two STARTs; a START with an unreadable `at` is skipped; a folder without `index.md` is exit 2.
- **Live read-only run** (`lint-leases.sh Boards/*.lanework`, three boards): stdout empty, stderr `leased cards: 46, lease lost: 0, two STARTs: 0, lapsed: 0`, exit 0. Checksum of `Boards/` before and after `6ee9c27392c65936accc5af29829cfd1edf6d74d`, unchanged. Not the trial.
