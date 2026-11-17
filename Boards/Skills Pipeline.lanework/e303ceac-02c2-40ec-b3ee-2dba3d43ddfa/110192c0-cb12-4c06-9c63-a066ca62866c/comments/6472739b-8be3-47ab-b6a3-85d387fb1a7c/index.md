---
schema: 1
kind: comment
created:  {at: 2026-11-16T11:23:03Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: the new `release.sh` block can kill the release silently, against "never stops the release"; one note.

- **Stance**: standard
- **Round**: 1
- **Card**: [Make the guide-version check advisory](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/110192c0-cb12-4c06-9c63-a066ca62866c)
- **Branch**: `card/110192c0-advisory-guide-check` at `007f71d`

**Blocking**

1. `scripts/release.sh @ 007f71d` "G=$(head -1 \"$BD/CLAUDE.md\" 2>/dev/null | ver lanework-agent-guide)": the script runs under `set -euo pipefail`, so when `head` (working tree) or `git show` (HEAD) fails, the pipeline fails and `set -e` exits before any hard check, with no message at all. Measured in scratch repos on a non-main branch, `--dry-run`: board `CLAUDE.md` absent from HEAD and tree: no output, exit 1 (the baseline prints the warnings, then `not on main`); `.schema/VERSION` missing: same silent exit 1; no `Lanework/` folder at all: same. An unborn `HEAD` also exits 128 silently. `ver` itself has `|| true`, but that guards only its own pipeline, not the outer one. Fix: append `|| true` to the four `G=`/`N=` assignments (or `set +o pipefail` inside the block), and add one smoke case for a missing board (assert the run still reaches `not on main`).

**Notes**

1. `scripts/release.sh @ 007f71d` "SG=$(ver lanework-agent-guide < CLAUDE.md)": a missing repo `CLAUDE.md` dies with a raw shell error, not a warning. Cannot happen in a real checkout, so not blocking; the same `|| true` guard covers it.
2. Smoke's `note:` line names the stamp as `lanework-agent-guide v100` (the whole `$S` string) after "stamp", where the release warning says `guide v10`. Cosmetic only.

**Checked**

- **Correctness vs done-when**: smoke never fails on the board's version in either direction.
  - Own full run in the worktree at `007f71d`: last line `smoke: 158 passed`, rc 0, no note (board v114 = stamp v114).
  - A scratch copy with the stamp set to v100: green, prints `note: the board is ahead of the stamp (guide v114, schema v1; stamp lanework-agent-guide v100, ...)`, then `ok` for the advisory line, `smoke: 158 passed`. This is the note path the card asks for.
  - Release warning measured in scratch repos: both warnings (working tree and `HEAD`) with versions, exit unchanged. Schema-ahead-only warns too. No stamp in `CLAUDE.md`: warns with `v?`. CRLF in `VERSION`: handled. Empty board `CLAUDE.md`: no crash. The missing-path cases fail; see Blocking.
  - Numeric compares: in smoke the `-gt` tests sit behind the `-z` branch, so no empty operand is possible. In `release.sh` they use `${G:-0}`, which is safe.
- **Project conduct**: stamp line `lanework-agent-guide v114`, `lanework-schema v1` untouched. `git diff --stat origin/main...HEAD`: 4 files only (`CLAUDE.md`, `README.md`, `scripts/release.sh`, `tests/smoke.sh`); nothing under `skills/` or `Lanework/`. `CLAUDE.md` and `README.md` wording matches the behavior (note in smoke, warning in release, neither fails).
- **Both paths**: working tree and `HEAD` both handled in the warning. The unreadable-version path in smoke prints a note and `ok`. The release block's missing-file path is the gap above.
- **Fail-before**: OWN RUN, mutation.
  - Replacing the warning `echo` with `:` in a scratch copy of `release.sh` and re-running the case's setup gives 0 warnings against the expected 2, so case 157 would fail. A first attempt that only deleted the line left an empty `if` and a syntax error, which is not a valid mutation; the `:` one is.
  - Gap the fixer admitted, now closed: a guide-version string appended to `skills/lanework/scripts/lib.sh` in a scratch copy gives smoke rc 1 with "a skill names a guide version (the stamp lives only in CLAUDE.md): .../lib.sh". A second stamp in `CLAUDE.md` gives rc 1 with "CLAUDE.md must carry exactly one guide stamp".
- **Test adequacy**: case 157 uses a throwaway repo under `$T`, `git init -b scratch`, inline `-c user.name/email`, no network (the script stops at `not on main` before `git fetch`), and cleans up with `$T`. It covers behind and current, but not a missing board, which is the blocking gap.
- **Blast radius**: matches the card's Touches table; `.github/workflows/smoke.yml` untouched as planned.
- **Population**: smoke 158 ok lines in two runs (worktree, stamp-v100 copy); `release.sh` scenarios: 11 scratch repos; the three failing ones are board `CLAUDE.md` absent, `VERSION` missing, no `Lanework/` folder (plus unborn `HEAD`).
